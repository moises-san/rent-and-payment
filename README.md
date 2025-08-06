# rent-and-payment
A simple Ruby class (PaymentInfo) that produces a list of payment information

Assumptions made in the solution:
1. Input to class functions are not validated beforehand. Input are validated inside the class before processing.\
Better practice would be to validate the input before invoking the class functions, but due to limitations presented by the problem statement, validation was done inside the class
2. Outputs were standardized, but with limitations:
    - if `rent` does not contain a `payment_method`, and was never adjusted, only `payment_date` is included\
    Example:
    ```
    [
        { payment_date: "2024-01-01" },
        { payment_date: "2024-02-01" },
        { payment_date: "2024-03-01" }
    ]
    ```
    - if `rent` does not contain a `payment_method`, but was adjusted, `payment_date` and `amount` is included\
    Example:
    ```
    [
        { payment_date: "2024-01-01", amount: 1000 },
        { payment_date: "2024-02-01", amount: 1000 },
        { payment_date: "2024-03-01", amount: 2000 }
    ]
    ```
    - if `rent` contains a `payment_method`, output includes `payment_date`, `amount`, and `method`\
    Example:
    ```
    [
        { payment_date: "2024-01-01", amount: 1000, method: "credit_card" },
        { payment_date: "2024-02-01", amount: 1000, method: "credit_card" },
        { payment_date: "2024-03-01", amount: 2000, method: "credit_card" }
    ]
    ```

# rent-and-payment-v2
An iteration to the previous program was implemented by refactoring the original classes and methods.
This iteration follows better engineering practices such as:
1. **_PaymentInfoV2 is now just an entity class._** \
Its sole function is to contain all details concerning the entity (payment details)
2. **_Methods are implemented through the PaymentInfoServiceV2 class._** \
Instead of keeping the logic inside the entity class, a service class was created to create and modify entities. \
\
Note, however, that the methods are statically called. The service class need not be instantiated before calling the functions. In real applications, an instance is first instantiated (usually, in a controller class for backend projects) before performing the functions. \
\
This separation of service class requires that the corresponding object be passed so that it may be modified accordingly. It mimics backend projects, where we get the necessary detail (i.e. primary key) of a record, fetch the object from the database, and modify according to the user input.

In this implementation, we assumed the following:
1. **_User input always follows the correct format._** \
Unlike the first implementation, validation was not performed in this iteration. This is to simplify the implementation of the program. Therefore, errors may or may not be caught if invalid input is passed to the functions.
2. **_Payment Dates follow a single output format._** \
The output format was standardized to include all keys from the 3<sup>rd</sup> scenario. Specifically, the ```payment_dates``` always follows the structure in the example below regardless of the scenario:
```
    [
        { payment_date: "2024-01-01", amount: 1000, method: "credit_card" },
        { payment_date: "2024-02-01", amount: 1000, method: "credit_card" },
        { payment_date: "2024-03-01", amount: 2000, method: "credit_card" }
    ]
    ```
