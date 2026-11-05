SELECT TxNumber, COUNT(*) AS Counts
FROM TxPayment
GROUP BY TxNumber
ORDER BY TxNumber;
