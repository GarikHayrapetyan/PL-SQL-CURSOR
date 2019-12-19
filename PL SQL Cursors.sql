/*1.	Use the cursor to review all employees and modify their salaries:
a.	Employees who earn less than 1000 get a 10% increase in salary
b.	Those who earn more than 1500 have a 10% reduction in salary. 
Display information about each change you make in output.
*/

SET SERVEROUTPUT ON;
DECLARE 
v_empno INTEGER; 
v_sal   INTEGER;
CURSOR cur IS SELECT e.empno, e.sal FROM emp e;

BEGIN
    OPEN cur;    
    LOOP
        FETCH cur INTO v_empno, v_sal;
        EXIT WHEN cur%NOTFOUND;
            dbms_output.put_line(v_empno || ' ' || v_sal);
           IF v_sal > 1500 THEN            
                    UPDATE emp
					SET sal = sal * 0.9
                    WHERE empno = v_empno;
                    dbms_output.put_line('Emplyee with number ' || v_empno || ' has salary lowered to ' || v_sal*0.9);               
           ELSIF v_sal < 1000 THEN                    
                 UPDATE emp
                 SET sal = sal * 1.1
				 WHERE empno = v_empno;
                 dbms_output.put_line('Emplyee with number  ' || v_empno || ' got a raise to ' || v_sal*1.1);         
            END IF;
    END LOOP;
    CLOSE cur;
END;


/*2. Transform the code from task 1 into a procedure so the earnings values (1000 and 1500) will be provided as input parameters of the procedure*/
SET Serveroutput ON;
CREATE OR REPLACE PROCEDURE ModifySalaries 
(p_lower emp.sal%type,
p_upper emp.sal%type)
IS 
CURSOR cur IS SELECT e.empno, e.sal FROM emp e;
v_empno emp.empno%type; 
v_sal   emp.sal%type;
BEGIN
    OPEN cur;    
    LOOP
        FETCH cur INTO v_empno, v_sal;
        EXIT WHEN cur%NOTFOUND;
            dbms_output.put_line(v_empno || ' ' || v_sal);
           IF v_sal > p_upper THEN            
                    UPDATE emp
					SET sal = sal * 0.9
                    WHERE empno = v_empno;
                    dbms_output.put_line('Emplyee with number ' || v_empno || ' has salary lowered to ' || v_sal*0.9);               
           ELSIF v_sal < p_lower THEN                    
                 UPDATE emp
                 SET sal = sal * 1.1
				 WHERE empno = v_empno;
                 dbms_output.put_line('Emplyee with number  ' || v_empno || ' got a raise to ' || v_sal*1.1);         
            END IF;
    END LOOP;
    CLOSE cur;
END ModifySalaries;

--procedure call
EXECUTE ModifySalaries(p_lower => 1000, p_upper => 1500);



/*3. In the procedure, find average salary in department specified by the parameter. 
Assign a commission (comm) to those employees (within provided department) who earn below the average. 
The commission should be equal to 5% of their current monthly salary.*/

SET Serveroutput ON;
CREATE OR REPLACE PROCEDURE GiveRaise 
(p_deptno dept.deptno%type)
IS 
CURSOR cur IS SELECT e.empno, e.sal FROM emp e WHERE e.deptno=p_deptno;
v_avgSalary emp.sal%type;
v_comm   emp.comm%type;
v_empno emp.empno%type; 
v_sal   emp.sal%type;
exc_noDeptFound EXCEPTION; --custom exception
BEGIN
    SELECT AVG(e.sal) INTO v_avgSalary
    FROM emp e
    WHERE e.deptno = p_deptno;
    
    IF v_avgsalary IS NULL THEN
        RAISE exc_noDeptFound;
    END IF;
    
    dbms_output.put_line('Average salary in department ' || p_deptno || ': ' || v_avgsalary);        
    
    OPEN cur;    
    LOOP
        FETCH cur INTO v_empno, v_sal;
        EXIT WHEN cur%NOTFOUND;
           IF v_sal < v_avgSalary THEN 
                v_comm := v_sal * 0.05;
                
				--OPEN cur; --uncomment this line to raise CURSOR_ALREADY_OPEN exception
				
                UPDATE emp
				SET comm = v_comm
                WHERE empno = v_empno;
                dbms_output.put_line('-Employee with number ' || v_empno || ' has a new comission assigned ' || v_comm);                  
            END IF;
    END LOOP;
    CLOSE cur;
    
EXCEPTION --exception handling
   WHEN exc_noDeptFound THEN --custom exception
       dbms_output.put_line('Department with provided id does not exist!'); 
   WHEN CURSOR_ALREADY_OPEN THEN --predefined exception      
       CLOSE cur; 
       dbms_output.put_line('Error - cursor was already open!'); 
END GiveRaise;

--CALL
EXECUTE GiveRaise(p_deptno => 10);
--more about error handling: https://docs.oracle.com/cd/B10501_01/appdev.920/a96624/07_errs.htm


/*4.	Create table Warehouse (IdItem, ItemName, Quantity) containing the quantities of individual items in the warehouse. 
Insert some sample records. 
Create a function, find the most-stocked item and reduce the amount of this item by 5 
(if the status is greater than or equal to 5, otherwise report an error). Return name of the changed item. 
Add exception handling.