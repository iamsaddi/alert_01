-- Flag whether the height of a product is within the control limits
SELECT
    b.*,
    CASE
        WHEN 
            b.height NOT BETWEEN b.lcl AND b.ucl
        THEN 'TRUE'
        ELSE 'FALSE'
    END as [alert]
FROM (
    SELECT
        a.*, 
        a.avg_height + 3*a.stddev_height/SQRT(5) AS ucl, 
        a.avg_height - 3*a.stddev_height/SQRT(5) AS lcl  
    FROM (
        SELECT 
            operator,
            ROW_NUMBER() OVER (ORDER BY item_no) AS row_number,  -- Add ORDER BY
            height, 
            AVG(height) OVER w AS avg_height, 
            STDEV(height) OVER w AS stddev_height
        FROM ..['datacamp_workspace_export_2024-$']  -- Replace with your actual table name
        WINDOW w AS (
            PARTITION BY operator 
            ORDER BY item_no 
           ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
        )
    ) AS a
    WHERE a.row_number >= 5
) AS b;
