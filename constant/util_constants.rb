DATE_FORMAT = "%Y-%m-%d"

DATE_REGEXP = /^\d{4}-\d{1,2}-\d{1,2}$/

RENT_REQUIRED_FIELDS = [:amount, :frequency, :start_date, :end_date]

RENT_CHANGE_REQUIRED_FIELDS = [:amount, :effective_date]

RENT_FREQUENCY = {
    monthly: { months: 1, days: 0 },
    fortnightly: { months: 0, days: 14 },
    weekly: { months: 0, days: 7 }
}

PAYMENT_METHOD = {
    credit_card: 2,
    bank_transfer: 3,
    instant: 0,
    none: 0
}
