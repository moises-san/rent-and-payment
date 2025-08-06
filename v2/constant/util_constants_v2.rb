DATE_FORMAT = "%Y-%m-%d"

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
