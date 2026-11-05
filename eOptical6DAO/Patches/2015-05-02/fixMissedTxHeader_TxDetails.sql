SELECT TxNumber, ControlNumber, COUNT(*) AS Counts
FROM TxDetails
GROUP BY TxNumber, ControlNumber
ORDER BY TxNumber;
