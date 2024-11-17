<?php
// Database connection
$host = "localhost";
$user = "root";
$password = "";
$dbname = "icloud-ems";

$conn = new mysqli($host, $user, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_FILES['file'])) {
    ini_set('max_execution_time', 600); // Set to 10 minutes

    // Validate file type
    if ($_FILES['file']['type'] === 'text/csv' || mime_content_type($_FILES['file']['tmp_name']) === 'text/plain') {
        // Move uploaded file to the "uploads" directory
        $csvFile = "uploads/" . basename($_FILES['file']['name']);
        if (!move_uploaded_file($_FILES['file']['tmp_name'], $csvFile)) {
            die("Failed to upload the file.");
        }

        // Open the CSV file
        if (($handle = fopen($csvFile, "r")) !== FALSE) {
            // Skip the header row
            $header = fgetcsv($handle);

            $batchSize = 500; // Number of rows per batch
            $rows = [];
            $rowCount = 0;

            while (($row = fgetcsv($handle, 1000, ",")) !== FALSE) {
                $rows[] = $row;
                $rowCount++;
            
                // Insert in batches
                if ($rowCount % $batchSize == 0) {
                    insertBatch($conn, $rows);
                    $rows = []; // Reset rows
                }
            }
            // Insert remaining rows
            if (!empty($rows)) {
                insertBatch($conn, $rows);
                insertCommonFeeCollections($conn, $rows);
            }

            fclose($handle);
            echo "CSV imported successfully. $rowCount rows inserted. $errorCount rows failed.";

            insertDistinctValues($conn, 'Faculty', 'Branches', 'branch_name');
            insertDistinctValues($conn, 'Fee_Category', 'FeeCategory', 'category_name');
            insertFeeCollectionTypesMapping($conn);

            insertDistinctValues($conn, 'Fee_Head', 'FeeTypes', 'fee_head');
            insertFeeTypeBranchMappings($conn);

            insertFinancialTransactions($conn, $rows);

        } else {
            echo "Failed to open the CSV file.";
        }
    } else {
        echo "Invalid file format! Please upload a valid CSV file.";
    }
} 

function insertBatch($conn, $rows) {
    $values = [];
    foreach ($rows as $row) {
        $escaped = array_map(function($value) use ($conn) {
            return $conn->real_escape_string($value);
        }, $row);
        $values[] = "('" . implode("','", $escaped) . "')";
    }

    $sql = "INSERT INTO Temporary_completedata 
        (Sr, Date, Academic_Year, Session, Alloted_Category, Voucher_Type, Voucher_No, Roll_No, Admno_UniqueId, Status, Fee_Category, Faculty, Program, Department, Batch, Receipt_No, Fee_Head, Due_Amount, Paid_Amount, Concession_Amount, Scholarship_Amount, Reverse_Concession_Amount, Write_Off_Amount, Adjusted_Amount, Refund_Amount, Fund_TranCfer_Amount, Remarks) 
        VALUES " . implode(",", $values);

    if (!$conn->query($sql)) {
        echo "Batch Error: " . $conn->error;
    }
}

function insertDistinctValues($conn, $column, $table, $field) {
    $sql = "SELECT DISTINCT $column FROM Temporary_completedata";
    $result = $conn->query($sql);

    while ($row = $result->fetch_assoc()) {
        $value = $row[$column];
        $sql_insert = "INSERT INTO $table ($field) VALUES ('$value')";
        $conn->query($sql_insert);
    }
}

function insertFeeCollectionTypesMapping($conn) {
    $sql = "SELECT branch_id FROM Branches";
    $branches = $conn->query($sql);

    while ($branch = $branches->fetch_assoc()) {
        for ($type_id = 1; $type_id <= 6; $type_id++) {
            $sql_insert_mapping = "INSERT INTO Branch_FeeCollectionTypes (branch_id, type_id) 
                                VALUES (" . $branch['branch_id'] . ", $type_id)";
            $conn->query($sql_insert_mapping);
        }
    }
}

function insertFeeTypeBranchMappings($conn) {
    $sql_branches = "SELECT branch_id FROM Branches";
    $branches = $conn->query($sql_branches);

    $sql_fees = "SELECT fee_id FROM FeeTypes";
    $fees = $conn->query($sql_fees);

    while ($branch = $branches->fetch_assoc()) {
        while ($fee = $fees->fetch_assoc()) {
            $sql_insert_mapping = "INSERT INTO Branch_FeeTypes (branch_id, fee_id) 
                                VALUES (" . $branch['branch_id'] . ", " . $fee['fee_id'] . ")";
            $conn->query($sql_insert_mapping);
        }
    }
}

function insertFinancialTransactions($conn, $rows) {
    foreach ($rows as $row) {
        // Insert into Financial_trans table (Parent)
        $transid = uniqid(); // Generate a unique transaction ID
        $amount = $row[17];  // Example for Due_Amount, adjust based on your column
        $moduleId = getModuleId($conn, $row[5]); // Assuming Voucher_Type or Entry Mode can identify the module
        $crdr = determineCrdr($row[5]);  // Determine Crdr (Credit or Debit)
        $entryMode = getEntryModeId($conn, $row[5]); // Determine Entry Mode (Concession, Scholarship, etc.)

        $sql = "INSERT INTO Financial_trans (transid, moduleId, amount, crdr, entryMode) 
                VALUES ('$transid', '$moduleId', '$amount', '$crdr', '$entryMode')";
        if (!$conn->query($sql)) {
            echo "Error inserting Financial_trans: " . $conn->error;
        }

        // Insert into Financial_trandetails table (Child)
        $headId = getFeeHeadId($conn, $row[16]); // Fee head from FeeTypes table
        $headName = $row[16]; // Fee head name
        $branchId = getBranchId($conn, $row[9]); // Branch from CSV

        $sql_details = "INSERT INTO Financial_trandetails (financialTranId, moduleId, amount, headId, crdr, brid, head_name) 
                        VALUES ('$transid', '$moduleId', '$amount', '$headId', '$crdr', '$branchId', '$headName')";
        if (!$conn->query($sql_details)) {
            echo "Error inserting Financial_trandetails: " . $conn->error;
        }
    }
}

// Insert Common Fee Collection and Headwise Records
function insertCommonFeeCollections($conn, $rows) {
    foreach ($rows as $row) {
        // Insert into Common_fee_collection (Parent)
        $transId = uniqid(); // Generate unique transId
        $admno = $row[8]; // Admno_UniqueId
        $rollno = $row[7]; // Roll_No
        $amount = $row[17]; // PaidAmount (or other relevant columns)
        $brId = getBranchId($conn, $row[9]); // Branch ID
        $academicYear = $row[3]; // Academic Year
        $financialYear = $row[3]; // Financial Year
        $receiptNo = generateReceiptNo($conn); // Generate unique receipt number
        $entryMode = getEntryModeId($conn, $row[5]); // Entry Mode
        $paidDate = date('Y-m-d', strtotime($row[17])); // Paid Date (adjust as necessary)
        $inactive = determineInactiveStatus($row[5]); // Inactive flag

        $sql = "INSERT INTO Common_fee_collection (moduleId, transId, admno, rollno, amount, brId, academicYear, financialYear, displayReceiptNo, entryMode, paidDate, inactive) 
                VALUES (1, '$transId', '$admno', '$rollno', '$amount', '$brId', '$academicYear', '$financialYear', '$receiptNo', '$entryMode', '$paidDate', '$inactive')";
        if (!$conn->query($sql)) {
            echo "Error inserting Common_fee_collection: " . $conn->error;
        }

        // Insert into Common_fee_collection_headwise (Child)
        $headId = getFeeHeadId($conn, $row[16]); // Fee head ID
        $headName = $row[16]; // Fee head name
        $amount = $row[17]; // Amount paid for this fee head

        $sql_headwise = "INSERT INTO Common_fee_collection_headwise (moduleId, receiptId, headId, headName, brid, amount) 
                         VALUES (1, '$transId', '$headId', '$headName', '$brId', '$amount')";
        if (!$conn->query($sql_headwise)) {
            echo "Error inserting Common_fee_collection_headwise: " . $conn->error;
        }
    }
}

function generateReceiptNo($conn) {
    // Generate a unique receipt number (e.g., auto-increment or custom logic)
    $sql = "SELECT MAX(receipt_id) FROM Common_fee_collection";
    $result = $conn->query($sql);
    $row = $result->fetch_assoc();
    return "2020-2021/AIE/C13/" . (intval($row['MAX(receipt_id)']) + 1);
}


function determineInactiveStatus($voucherType) {
    if (in_array($voucherType, ['REVERSAL', 'REVERT'])) {
        return 1; // Reversed entry
    }
    return 0; // Active entry
}

function getModuleId($conn, $voucherType) {
    // Define how you get the module ID from the module table based on voucher type or other logic
    $moduleMap = [
        'academic' => 1,
        'academicmisc' => 11,
        'hostel' => 2,
        'hostelmisc' => 12,
        'transport' => 3,
        'transportmisc' => 13
    ];
    return $moduleMap[$voucherType] ?? null;
}
function determineCrdr($voucherType) {
    // Example logic to determine whether it's a Debit or Credit (Crdr)
    if (in_array($voucherType, ['DUE', 'WRITE_OFF'])) {
        return 'D'; // Debit
    } elseif (in_array($voucherType, ['CONCESSION', 'SCHOLARSHIP'])) {
        return 'C'; // Credit
    }
    return null;
}

function getEntryModeId($conn, $voucherType) {
    // Logic to fetch entry mode from EntryMode table based on voucher type
    $sql = "SELECT entryModeId FROM EntryMode WHERE voucherType = '$voucherType'";
    $result = $conn->query($sql);
    if ($result && $row = $result->fetch_assoc()) {
        return $row['entryModeId'];
    }
    return null;
}
function getFeeHeadId($conn, $feeHead) {
    // Logic to get FeeHeadId from FeeTypes table based on Fee Head
    $sql = "SELECT fee_id FROM FeeTypes WHERE fee_head = '$feeHead'";
    $result = $conn->query($sql);
    if ($result && $row = $result->fetch_assoc()) {
        return $row['fee_id'];
    }
    return null;
}
function getBranchId($conn, $branchName) {
    // Logic to get BranchId from Branches table based on branch name
    $sql = "SELECT branch_id FROM Branches WHERE branch_name = '$branchName'";
    $result = $conn->query($sql);
    if ($result && $row = $result->fetch_assoc()) {
        return $row['branch_id'];
    }
    return null;
}

$conn->close();
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Import CSV</title>
    <style>
        /* General Styles */
        body {
            font-family: 'Arial', sans-serif;
            background: linear-gradient(to bottom right, #6a11cb, #2575fc);
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }

        .container {
            background-color: #fff;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
            width: 100%;
            max-width: 600px;
            text-align: center;
        }

        h1 {
            font-size: 2.5em;
            color: #333;
            margin-bottom: 30px;
            text-transform: uppercase;
            letter-spacing: 2px;
            font-weight: bold;
        }

        /* Form Styling */
        form {
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        label {
            font-size: 1.2em;
            color: #333;
            margin-bottom: 15px;
            font-weight: bold;
            text-align: left;
            width: 100%;
            padding-left: 10px;
        }

        input[type="file"] {
            font-size: 1em;
            padding: 15px;
            width: 100%;
            border: 2px solid #ddd;
            border-radius: 8px;
            outline: none;
            background-color: #fafafa;
            margin-bottom: 30px;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        input[type="file"]:hover {
            border-color: #2575fc;
            background-color: #f0f8ff;
        }

        input[type="file"]::file-selector-button {
            font-size: 1em;
            padding: 10px 20px;
            background-color: #2575fc;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }

        input[type="file"]::file-selector-button:hover {
            background-color: #6a11cb;
        }

        button {
            background: linear-gradient(145deg, #2575fc, #6a11cb);
            color: #fff;
            font-size: 1.1em;
            padding: 15px 30px;
            border: none;
            border-radius: 30px;
            cursor: pointer;
            transition: all 0.3s ease;
            width: 100%;
        }

        button:hover {
            transform: translateY(-3px);
            background: linear-gradient(145deg, #6a11cb, #2575fc);
        }

        button:active {
            transform: translateY(1px);
            background: linear-gradient(145deg, #2575fc, #6a11cb);
        }

        /* Icon and Info Styling */
        .info-text {
            font-size: 1em;
            color: #777;
            margin-top: 20px;
        }

        .info-text a {
            color: #2575fc;
            text-decoration: none;
        }

        .info-text a:hover {
            text-decoration: underline;
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .container {
                padding: 25px;
                width: 80%;
            }

            h1 {
                font-size: 2em;
            }

            button {
                font-size: 1em;
                padding: 12px 25px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Upload CSV File</h1>
        <form action="" method="post" enctype="multipart/form-data">
            <label for="file">Select CSV File</label>
            <input type="file" name="file" id="file" accept=".csv" required>
            <button type="submit">
                <span>&#8593;</span> Upload CSV
            </button>
        </form>
        <div class="info-text">
            <p>Need help? Check our <a href="#">documentation</a> or contact <a href="#">support</a>.</p>
        </div>
    </div>
</body>
</html>
