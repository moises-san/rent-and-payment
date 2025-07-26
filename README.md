# rent-and-payment
A simple Ruby class that produces a list of payment information

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
