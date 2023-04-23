#1. Find the highest credit limit given to a customer
select max(creditlimit) from customers;

#2. Find the highest credit limit given to a customer in the country USA
select max(creditlimit) from customers 
where country = 'USA';

#3. What is name of the customer that has the highest payment amount in single payment?
select customername from customers 
where customernumber = 
(select customernumber from payments 
where amount = (select max(amount) from payments))

#4. List countries where customers buy the product "The Titanic"
select distinct country from customers where customernumber in 
(select customernumber from orders where 
ordernumber in (select ordernumber from orderdetails where productcode = 
(select productcode from products 
where productname = 'The Titanic')))
order by country;

#5. Which product line has maximum sales in units?
SELECT PRODUCTLINE,SUM(PRODUCTQUANTITY) AS LINEQTY
FROM(SELECT B.PRODUCTLINE,A.PRODUCTCODE,A.PRODUCTQUANTITY
FROM PRODUCTS B,(SELECT PRODUCTCODE,SUM(QUANTITYORDERED) AS PRODUCTQUANTITY FROM ORDERDETAILS
GROUP BY PRODUCTCODE) A
WHERE B.PRODUCTCODE = A.PRODUCTCODE) C
GROUP BY PRODUCTLINE
ORDER BY LINEQTY DESC LIMIT 1; 

#6. Which product line has maximum sales in $ terms? What is sales amount?
select a.productline, b.totalSales from products a
left join
(select productcode,sum(quantityordered*priceEach) as totalSales
from orderdetails 
group by productcode) b
on a.productcode = b.productcode
where b.totalSales = (
select max(c.totalSales) from (

select a.productline, b.totalSales from products a
left join
(select productcode,sum(quantityordered*priceEach) as totalSales
from orderdetails 
group by productcode) b
on a.productcode = b.productcode) c)


#7. Which sales rep has highest sales in $ terms?
select g.lastname, g.firstname, g.totalsales from (
select d.salesrepemployeenumber, f.lastname, f.firstname, sum(e.sales) as totalSales
from customers d, (

select b.customernumber,  c.sales
from orders b, (select a.ordernumber, sum(quantityordered * priceEach) as Sales
from orderdetails a
group by a.ordernumber) c
where b.ordernumber = c.ordernumber) e, employees f

where d.customernumber = e.customernumber
and d.salesrepemployeenumber = f.employeenumber
group by d.salesrepemployeenumber
order by totalsales desc
limit 1) g


#8. Which sales manager has the highest average sales per sales rep?
select h.lastname, h.firstname, i.AvgSales from employees h, (

select g.reportsto, sum(g.totalsales)/count(g.salesrepemployeenumber) as AvgSales from


(select d.salesrepemployeenumber, f.reportsto, sum(e.sales) as totalSales
from customers d, (

select b.customernumber,  c.sales
from orders b, (select a.ordernumber, sum(quantityordered * priceEach) as Sales
from orderdetails a
group by a.ordernumber) c
where b.ordernumber = c.ordernumber) e, employees f

where d.customernumber = e.customernumber
and d.salesrepemployeenumber = f.employeenumber
group by d.salesrepemployeenumber
) g
group by g.reportsto) i
where h.employeenumber = i.reportsto
order by i.AvgSales DESC
limit 1

#9. Which customer has highest outstanding? outstanding= sales- payment
select customerName, Outstanding
from customers e, 
(

select c.customernumber, (c.totSales - d.totPayments) as Outstanding from
(
select a.customernumber, sum(b.priceEach * b.quantityordered) as totSales
from orders a, orderdetails b
where a.ordernumber = b.ordernumber
group by a.customernumber) c,


(select customernumber, sum(amount) as totPayments
from payments
group by customernumber) d
where c.customernumber = d.customernumber
and (c.totSales - d.totPayments) > 0
order by OutStanding DESC
limit 1) f
where e.customernumber = f.customernumber


#10.Which country has the highest outstanding?
select e.country,sum(f.outstanding) as cntOutstanding from
customers e, 
(

select c.customernumber, (c.totSales - d.totPayments) as Outstanding from
(
select a.customernumber,  sum(b.priceEach * b.quantityordered) as totSales
from orders a, orderdetails b
where a.ordernumber = b.ordernumber
group by a.customernumber) c,


(select customernumber, sum(amount) as totPayments
from payments
group by customernumber) d
where c.customernumber = d.customernumber
and (c.totSales - d.totPayments) > 0
) f
where e.customernumber = f.customernumber
group by e.country
order by cntOutstanding desc
limit 1


#11. Which customer has outstanding more than credit limit?
select e.customername
from customers e, 
(

select c.customernumber, (c.totSales - d.totPayments) as Outstanding from
(
select a.customernumber,  sum(b.priceEach * b.quantityordered) as totSales
from orders a, orderdetails b
where a.ordernumber = b.ordernumber
group by a.customernumber) c,


(select customernumber, sum(amount) as totPayments
from payments
group by customernumber) d
where c.customernumber = d.customernumber
and (c.totSales - d.totPayments) > 0
) f
where e.customernumber = f.customernumber
and e.creditlimit < f.outstanding

# 12. How many cars were sold from Classic Cars that were manufactured after 1999. 
select sum(quantityordered) 
from orderdetails 
where productcode in (select productcode
from products
where productname like "2%"
and productline = "Classic Cars")

# 13. What is the annual sales trend?
select year(a.orderdate) as Year, sum(b.quantityordered * b.priceEach) as Sales
from orders a, orderdetails b
where a.ordernumber = b.ordernumber
group by year(a.orderdate) 
order by Year ASC

#14. Which product has the highest % range of price? Calculated as (maximum price - minimum price)/(minimum price) %
select b.productname as ProductName,  ((max(a.priceeach) - min(a.priceeach))/min(a.priceeach)) * 100 as PriceRange
from orderdetails a, products b
where a.productcode = b.productcode
group by a.productcode
order by PriceRange  DESC
limit 1


