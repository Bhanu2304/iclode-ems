INSERT INTO `entrymode` (`id`, `entrymodename`, `crdr`, `entrymodeno`) VALUES
(1, 'DUE', 'D', 0),
(2, 'REVDUE', 'C', 12),
(3, 'SCHOLARSHIP', 'C', 15),
(4, 'SCHOLARSHIPREV/REVCONCESSION', 'D', 16),
(5, 'CONCESSION', 'C', 15),
(6, 'RCPT', 'C', 0),
(7, 'REVRCPT', 'D', 0),
(8, 'JV', 'C', 14),
(9, 'REVJV', 'D', 14),
(10, 'PMT', 'D', 1),
(11, 'REVPMT', 'C', 1),
(12, 'Fundtransfer', '+ve and -ve', 1);

INSERT INTO `module` (`moduleid`, `modulename`) VALUES
(1, 'academic'),
(11, 'academicmisc'),
(2, 'hostel'),
(22, 'hostelmisc'),
(3, 'transport'),
(33, 'transportmisc');

INSERT INTO FeeCollectionTypes (type_name) VALUES 
    ('academic'), 
    ('academicmisc'), 
    ('hostel'), 
    ('hostelmisc'), 
    ('transport'), 
    ('transportmisc');
    
SELECT 
    COUNT(*) AS total_records,
    SUM(Due_Amount) AS total_due,
    SUM(Paid_Amount) AS total_paid,
    SUM(Concession_Amount) AS total_concession,
    SUM(Scholarship_Amount) AS total_scholarship,
    SUM(Refund_Amount) AS total_refund
FROM `temporary_completedata`;
