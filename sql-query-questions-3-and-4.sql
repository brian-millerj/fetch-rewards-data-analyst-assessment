--Question 3: When considering average spend from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
--Question 4: When considering total number of items purchased from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
SELECT
  rewardsReceiptStatus as receiptStatus,
  ROUND(AVG(totalSpent),2) AS Average_totalSpent,
  SUM(purchasedItemCount) AS Total_purchasedItemCount
FROM
  FetchRewards.dbo.receipts
WHERE
  rewardsReceiptStatus in ('FINISHED', 'REJECTED')
GROUP BY
  rewardsReceiptStatus;