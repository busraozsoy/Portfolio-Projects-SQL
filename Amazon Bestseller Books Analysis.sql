/*

Amazon Bestselling Books 2009 - 2019

*/


SELECT * FROM amazon_books 

-- Looking at the count of best-selling books by Name and Author

SELECT Name,COUNT(Name) as best_selling_books,Author FROM amazon_books
GROUP BY Name,Author 
ORDER BY COUNT(Name) DESC

--Looking at the count of the most expensive books by Name and Author."

SELECT Name,Author, MAX(Price)  as expensive_book
FROM amazon_books    
GROUP BY Name,Author
ORDER BY MAX(Price) DESC

--Looking at the count of the highest-rated books by Name and Author.

SELECT Name,Author, MAX(User_Rating) highest_rating
FROM amazon_books    
GROUP BY Name,Author 
ORDER BY MAX(User_Rating) DESC

--Comparison of Average Book Prices Between Consecutive Years

 WITH sales as (
SELECT Year,AVG(Price) average_sales
FROM amazon_books  
GROUP BY  Year
)

SELECT Year,average_sales,
LAG(average_sales, 1) OVER (ORDER BY Year ) AS  previous_sales,
average_sales - LAG(average_sales, 1) OVER (ORDER BY Year) AS difference
FROM sales

--Book Count by Genre

SELECT Genre,COUNT(Genre) FROM amazon_books
GROUP BY Genre

--Top Selling Author and Their Most Common Genre

SELECT Author,Genre FROM amazon_books
GROUP BY Author,Genre
ORDER BY COUNT(Author) DESC

--Average Reviews Per Year

SELECT Year,AVG(Reviews) average_sales
FROM amazon_books  
GROUP BY  Year



