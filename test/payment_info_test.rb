require 'test/unit'
require_relative 'test_utils'
require_relative '../exception/invalid_input_error'
require_relative '../payment_info'


class PaymentInfoTest


    class BasicRentTest < Test::Unit::TestCase

        # PROVIDED TEST CASE:
        def test_basic_rent_monthly
            rent = TestUtils.generate_basic_rent_input

            expected_result = [
                { payment_date: "2024-01-01" },
                { payment_date: "2024-02-01" },
                { payment_date: "2024-03-01" }
            ]

            payment_info = PaymentInfo.new(rent)
            payment_dates = payment_info.get_payment_dates

            assert_equal(expected_result, payment_dates)
        end

        # CUSTOM TEST CASES:
        def test_basic_rent_fortnightly
            rent = TestUtils.generate_basic_rent_input
            rent[:frequency] = "fortnightly"
            rent[:end_date] = "2024-02-05"

            expected_result = [
                { payment_date: "2024-01-01" },
                { payment_date: "2024-01-15" },
                { payment_date: "2024-01-29" }
            ]

            payment_info = PaymentInfo.new(rent)
            payment_dates = payment_info.get_payment_dates

            assert_equal(expected_result, payment_dates)
        end

        def test_basic_rent_weekly
            rent = TestUtils.generate_basic_rent_input
            rent[:frequency] = "weekly"
            rent[:end_date] = "2024-02-05"

            expected_result = [
                { payment_date: "2024-01-01" },
                { payment_date: "2024-01-08" },
                { payment_date: "2024-01-15" },
                { payment_date: "2024-01-22" },
                { payment_date: "2024-01-29" }
            ]

            payment_info = PaymentInfo.new(rent)
            payment_dates = payment_info.get_payment_dates

            assert_equal(expected_result, payment_dates)
        end

        def test_basic_rent_end_of_month_due
            rent = TestUtils.generate_basic_rent_input
            rent[:start_date] = "2024-01-31"
            rent[:end_date] = "2024-04-30"

            expected_result = [
                { payment_date: "2024-01-31" },
                { payment_date: "2024-02-29" },
                { payment_date: "2024-03-31" }
            ]

            payment_info = PaymentInfo.new(rent)
            payment_dates = payment_info.get_payment_dates

            assert_equal(expected_result, payment_dates)
        end

        def test_basic_rent_same_date
            rent = TestUtils.generate_basic_rent_input
            rent[:end_date] = "2024-01-01"

            expected_result = []

            payment_info = PaymentInfo.new(rent)
            payment_dates = payment_info.get_payment_dates

            assert_equal(expected_result, payment_dates)
            assert_equal(0, payment_dates.length)
        end

        def test_basic_rent_invalid_range
            rent = TestUtils.generate_basic_rent_input
            rent[:end_date] = "2023-11-01"

            expected_result = []

            payment_info = PaymentInfo.new(rent)
            payment_dates = payment_info.get_payment_dates

            assert_equal(expected_result, payment_dates)
            assert_equal(0, payment_dates.length)
        end

    end


    class AdjustRentTest < Test::Unit::TestCase

        # PROVIDED TEST CASE:
        def test_adjust_basic_rent_once
            rent = TestUtils.generate_basic_rent_input
            rent_change = {
                amount: 1200,
                effective_date: "2024-02-15"
            }

            expected_result = [
                { payment_date: "2024-01-01", amount: 1000 },
                { payment_date: "2024-02-01", amount: 1000 },
                { payment_date: "2024-03-01", amount: 1200 }
            ]

            payment_info = PaymentInfo.new(rent)
            payment_dates = payment_info.adjust_rent(rent_change)

            assert_equal(expected_result, payment_dates)
        end

        # CUSTOM TEST CASES:
        def test_adjust_basic_rent_multiple
            rent = TestUtils.generate_basic_rent_input
            rent[:frequency] = "fortnightly"
            rent[:end_date] = "2024-03-11"
            rent_change1 = {
                amount: 1200,
                effective_date: "2024-01-18"
            }
            rent_change2 = {
                amount: 1500,
                effective_date: "2024-02-15"
            }

            expected_result = [
                { payment_date: "2024-01-01", amount: 1000 },
                { payment_date: "2024-01-15", amount: 1000 },
                { payment_date: "2024-01-29", amount: 1200 },
                { payment_date: "2024-02-12", amount: 1200 },
                { payment_date: "2024-02-26", amount: 1500 }
            ]

            payment_info = PaymentInfo.new(rent)
            payment_info.adjust_rent(rent_change1)
            payment_dates = payment_info.adjust_rent(rent_change2)

            assert_equal(expected_result, payment_dates)
        end

        def test_adjust_rent_with_payment_method_once
            rent = TestUtils.generate_basic_rent_input
            rent[:payment_method] = "credit_card"
            rent_change = {
                amount: 1200,
                effective_date: "2024-01-18"
            }

            expected_result = [
                { payment_date: "2023-12-30", amount: 1000, method: "credit_card" },
                { payment_date: "2024-01-30", amount: 1200, method: "credit_card" },
                { payment_date: "2024-02-28", amount: 1200, method: "credit_card" }
            ]

            payment_info = PaymentInfo.new(rent)
            payment_dates = payment_info.adjust_rent(rent_change)

            assert_equal(expected_result, payment_dates)
        end

        def test_adjust_rent_with_payment_method_multiple
            rent = TestUtils.generate_basic_rent_input
            rent[:payment_method] = "credit_card"
            rent_change1 = {
                amount: 1200,
                effective_date: "2024-01-18"
            }
            rent_change2 = {
                amount: 2000,
                effective_date: "2024-02-20"
            }

            expected_result = [
                { payment_date: "2023-12-30", amount: 1000, method: "credit_card" },
                { payment_date: "2024-01-30", amount: 1200, method: "credit_card" },
                { payment_date: "2024-02-28", amount: 2000, method: "credit_card" }
            ]

            payment_info = PaymentInfo.new(rent)
            payment_info.adjust_rent(rent_change1)
            payment_dates = payment_info.adjust_rent(rent_change2)

            assert_equal(expected_result, payment_dates)
        end

        def test_adjust_basic_rent_then_add_payment_method
            rent = TestUtils.generate_basic_rent_input
            rent_change = {
                amount: 1200,
                effective_date: "2024-01-15"
            }

            expected_result = [
                { payment_date: "2023-12-30", amount: 1000, method: "credit_card" },
                { payment_date: "2024-01-30", amount: 1200, method: "credit_card" },
                { payment_date: "2024-02-28", amount: 1200, method: "credit_card" }
            ]

            payment_info = PaymentInfo.new(rent)
            payment_info.adjust_rent(rent_change)
            payment_dates = payment_info.add_or_change_payment_method("credit_card")

            assert_equal(expected_result, payment_dates)

        end

        def test_add_payment_method_then_adjust_rent
            rent = TestUtils.generate_basic_rent_input
            rent_change = {
                amount: 1200,
                effective_date: "2024-01-15"
            }

            expected_result = [
                { payment_date: "2023-12-30", amount: 1000, method: "credit_card" },
                { payment_date: "2024-01-30", amount: 1200, method: "credit_card" },
                { payment_date: "2024-02-28", amount: 1200, method: "credit_card" }
            ]

            payment_info = PaymentInfo.new(rent)
            payment_info.add_or_change_payment_method("credit_card")
            payment_dates = payment_info.adjust_rent(rent_change)

            assert_equal(expected_result, payment_dates)
        end

        def test_adjust_date_equal_to_payment_date
            rent = TestUtils.generate_basic_rent_input
            rent_change = {
                amount: 1200,
                effective_date: "2024-02-01"
            }

            expected_result = [
                { payment_date: "2024-01-01", amount: 1000 },
                { payment_date: "2024-02-01", amount: 1200 },
                { payment_date: "2024-03-01", amount: 1200 }
            ]

            payment_info = PaymentInfo.new(rent)
            payment_dates = payment_info.adjust_rent(rent_change)

            assert_equal(expected_result, payment_dates)
        end

        def test_advance_rent_with_adjustment
            rent = TestUtils.generate_basic_rent_input
            rent[:payment_method] = "credit_card"
            rent_change = {
                amount: 2000,
                effective_date: "2024-03-01"
            }

            expected_result = [
                { payment_date: "2023-12-30", amount: 1000, method: "credit_card" },
                { payment_date: "2024-01-30", amount: 1000, method: "credit_card" },
                { payment_date: "2024-02-28", amount: 2000, method: "credit_card" }
            ]

            payment_info = PaymentInfo.new(rent)
            payment_dates = payment_info.adjust_rent(rent_change)

            assert_equal(expected_result, payment_dates)
        end

    end


    class RentWithMethodTest < Test::Unit::TestCase

        # PROVIDED TEST CASE:
        def test_rent_with_payment_method_credit
            rent = TestUtils.generate_basic_rent_input
            rent[:payment_method] = "credit_card"

            expected_result = [
                { payment_date: "2023-12-30", amount: 1000, method: "credit_card" },
                { payment_date: "2024-01-30", amount: 1000, method: "credit_card" },
                { payment_date: "2024-02-28", amount: 1000, method: "credit_card" }
            ]

            payment_info = PaymentInfo.new(rent)
            payment_dates = payment_info.get_payment_dates

            assert_equal(expected_result, payment_dates)
        end

        # CUSTOM TEST CASES:
        def test_rent_with_payment_method_bank
            rent = TestUtils.generate_basic_rent_input
            rent[:payment_method] = "bank_transfer"

            expected_result = [
                { payment_date: "2023-12-29", amount: 1000, method: "bank_transfer" },
                { payment_date: "2024-01-29", amount: 1000, method: "bank_transfer" },
                { payment_date: "2024-02-27", amount: 1000, method: "bank_transfer" }
            ]

            payment_info = PaymentInfo.new(rent)
            payment_dates = payment_info.get_payment_dates

            assert_equal(expected_result, payment_dates)
        end

        def test_rent_with_payment_method_instant
            rent = TestUtils.generate_basic_rent_input
            rent[:payment_method] = "instant"

            expected_result = [
                { payment_date: "2024-01-01", amount: 1000, method: "instant" },
                { payment_date: "2024-02-01", amount: 1000, method: "instant" },
                { payment_date: "2024-03-01", amount: 1000, method: "instant" }
            ]

            payment_info = PaymentInfo.new(rent)
            payment_dates = payment_info.get_payment_dates

            assert_equal(expected_result, payment_dates)
        end

        def test_add_payment_method_to_basic
            rent = TestUtils.generate_basic_rent_input

            expected_result = [
                { payment_date: "2023-12-29", amount: 1000, method: "bank_transfer" },
                { payment_date: "2024-01-29", amount: 1000, method: "bank_transfer" },
                { payment_date: "2024-02-27", amount: 1000, method: "bank_transfer" }
            ]

            payment_info = PaymentInfo.new(rent)
            payment_dates = payment_info.add_or_change_payment_method("bank_transfer")

            assert_equal(expected_result, payment_dates)
        end

        def test_change_payment_method
            rent = TestUtils.generate_basic_rent_input
            rent[:payment_method] = "bank_transfer"

            expected_result = [
                { payment_date: "2024-01-01", amount: 1000, method: "instant" },
                { payment_date: "2024-02-01", amount: 1000, method: "instant" },
                { payment_date: "2024-03-01", amount: 1000, method: "instant" }
            ]

            payment_info = PaymentInfo.new(rent)
            payment_dates = payment_info.add_or_change_payment_method("instant")

            assert_equal(expected_result, payment_dates)
        end

    end


    class ValidationTests < Test::Unit::TestCase

        def test_incomplete_rent
            rent = { amount: 1000 }
            assert_raise(InvalidInputError.new("There is a missing required field in your input.")) { PaymentInfo.new(rent) }
        end

        def test_invalid_rent_amount
            rent = TestUtils.generate_basic_rent_input
            rent[:amount] = "inv"
            assert_raise(InvalidInputError.new("Rent amount should be numerical.")) { PaymentInfo.new(rent) }
        end

        def test_invalid_frequency
            rent = TestUtils.generate_basic_rent_input
            rent[:frequency] = "inv"
            assert_raise(InvalidInputError.new("Rent frequency is invalid.")) { PaymentInfo.new(rent) }
        end

        def test_invalid_payment_method
            rent = TestUtils.generate_basic_rent_input
            rent[:payment_method] = "inv"
            assert_raise(InvalidInputError.new("Payment method is invalid.")) { PaymentInfo.new(rent) }
        end

        def test_invalid_date_format
            rent = TestUtils.generate_basic_rent_input
            rent[:start_date] = "2024-02-40"
            assert_raise(Date::Error.new("invalid date")) { PaymentInfo.new(rent) }

            rent[:end_date] = "2024-02-40"
            assert_raise(Date::Error.new("invalid date")) { PaymentInfo.new(rent) }

            rent[:start_date] = "inv"
            assert_raise(InvalidInputError.new("Format for date/s should follow YYYY-MM-DD.")) { PaymentInfo.new(rent) }

            rent[:end_date] = "inv"
            assert_raise(InvalidInputError.new("Format for date/s should follow YYYY-MM-DD.")) { PaymentInfo.new(rent) }
        end

        def test_incomplete_rent_change
            rent = TestUtils.generate_basic_rent_input
            rent_change = { amount: 1200 }
            payment_info = PaymentInfo.new(rent)
            assert_raise(InvalidInputError.new("There is a missing required field in your input.")) { payment_info.adjust_rent(rent_change) }
        end

        def test_invalid_rent_change_amount
            rent = TestUtils.generate_basic_rent_input
            rent_change = {
                amount: "inv",
                effective_date: "2024-01-15"
            }
            payment_info = PaymentInfo.new(rent)
            assert_raise(InvalidInputError.new("Change amount should be numerical.")) { payment_info.adjust_rent(rent_change) }
        end

        def test_invalid_rent_change_date_format
            rent = TestUtils.generate_basic_rent_input
            rent_change = {
                amount: 2000,
                effective_date: "2024-01-45"
            }
            payment_info = PaymentInfo.new(rent)
            assert_raise(Date::Error.new("invalid date")) { payment_info.adjust_rent(rent_change) }

            rent_change[:effective_date] = "inv"
            assert_raise(InvalidInputError.new("Format for date/s should follow YYYY-MM-DD.")) { payment_info.adjust_rent(rent_change) }
        end

        def test_add_invalid_payment_method
            rent = TestUtils.generate_basic_rent_input
            payment_info = PaymentInfo.new(rent)
            assert_raise(InvalidInputError.new("Payment method is invalid.")) { payment_info.add_or_change_payment_method("inv") }
        end

    end

end
