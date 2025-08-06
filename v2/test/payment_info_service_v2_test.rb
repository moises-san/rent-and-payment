require 'test/unit'
require_relative '../payment_info_service_v2'
require_relative 'test_utils_v2'


class PaymentInfoServiceV2Test

    class BasicRentTest < Test::Unit::TestCase

        # PROVIDED TEST CASE:
        def test_basic_rent_monthly
            rent = TestUtilsV2.generate_basic_rent_input

            expected_result = [
                { payment_date: "2024-01-01", amount: 1000, method: "" },
                { payment_date: "2024-02-01", amount: 1000, method: "" },
                { payment_date: "2024-03-01", amount: 1000, method: "" }
            ]

            payment_info = PaymentInfoServiceV2.build_payment_info(rent)
            payment_dates = payment_info.payment_dates

            assert_equal(expected_result, payment_dates)
        end

        # CUSTOM TEST CASES:
        def test_basic_rent_fortnightly
            rent = TestUtilsV2.generate_basic_rent_input
            rent[:frequency] = "fortnightly"
            rent[:end_date] = "2024-02-05"

            expected_result = [
                { payment_date: "2024-01-01", amount: 1000, method: "" },
                { payment_date: "2024-01-15", amount: 1000, method: "" },
                { payment_date: "2024-01-29", amount: 1000, method: "" }
            ]

            payment_info = PaymentInfoServiceV2.build_payment_info(rent)
            payment_dates = payment_info.payment_dates

            assert_equal(expected_result, payment_dates)
        end

        def test_basic_rent_weekly
            rent = TestUtilsV2.generate_basic_rent_input
            rent[:frequency] = "weekly"
            rent[:end_date] = "2024-02-05"

            expected_result = [
                { payment_date: "2024-01-01", amount: 1000, method: "" },
                { payment_date: "2024-01-08", amount: 1000, method: "" },
                { payment_date: "2024-01-15", amount: 1000, method: "" },
                { payment_date: "2024-01-22", amount: 1000, method: "" },
                { payment_date: "2024-01-29", amount: 1000, method: "" }
            ]

            payment_info = PaymentInfoServiceV2.build_payment_info(rent)
            payment_dates = payment_info.payment_dates

            assert_equal(expected_result, payment_dates)
        end

        def test_basic_rent_end_of_month_due
            rent = TestUtilsV2.generate_basic_rent_input
            rent[:start_date] = "2024-01-31"
            rent[:end_date] = "2024-04-30"

            expected_result = [
                { payment_date: "2024-01-31", amount: 1000, method: "" },
                { payment_date: "2024-02-29", amount: 1000, method: "" },
                { payment_date: "2024-03-31", amount: 1000, method: "" }
            ]

            payment_info = PaymentInfoServiceV2.build_payment_info(rent)
            payment_dates = payment_info.payment_dates

            assert_equal(expected_result, payment_dates)
        end

        def test_basic_rent_same_date
            rent = TestUtilsV2.generate_basic_rent_input
            rent[:end_date] = "2024-01-01"

            expected_result = []

            payment_info = PaymentInfoServiceV2.build_payment_info(rent)
            payment_dates = payment_info.payment_dates

            assert_equal(expected_result, payment_dates)
            assert_equal(0, payment_dates.length)
        end

        def test_basic_rent_invalid_range
            rent = TestUtilsV2.generate_basic_rent_input
            rent[:end_date] = "2023-11-01"

            expected_result = []

            payment_info = PaymentInfoServiceV2.build_payment_info(rent)
            payment_dates = payment_info.payment_dates

            assert_equal(expected_result, payment_dates)
            assert_equal(0, payment_dates.length)
        end

    end


    class AdjustRentTest < Test::Unit::TestCase

        # PROVIDED TEST CASE:
        def test_adjust_basic_rent_once
            rent = TestUtilsV2.generate_basic_rent_input
            rent_change = {
                amount: 1200,
                effective_date: "2024-02-15"
            }

            expected_result = [
                { payment_date: "2024-01-01", amount: 1000, method: "" },
                { payment_date: "2024-02-01", amount: 1000, method: "" },
                { payment_date: "2024-03-01", amount: 1200, method: "" }
            ]

            payment_info = PaymentInfoServiceV2.build_payment_info(rent)
            payment_dates = PaymentInfoServiceV2.adjust_rent(payment_info, rent_change)

            assert_equal(expected_result, payment_dates)
            assert_equal(expected_result, payment_info.payment_dates)
        end

        # CUSTOM TEST CASES:
        def test_adjust_basic_rent_multiple
            rent = TestUtilsV2.generate_basic_rent_input
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
                { payment_date: "2024-01-01", amount: 1000, method: "" },
                { payment_date: "2024-01-15", amount: 1000, method: "" },
                { payment_date: "2024-01-29", amount: 1200, method: "" },
                { payment_date: "2024-02-12", amount: 1200, method: "" },
                { payment_date: "2024-02-26", amount: 1500, method: "" }
            ]

            payment_info = PaymentInfoServiceV2.build_payment_info(rent)
            PaymentInfoServiceV2.adjust_rent(payment_info, rent_change1)
            payment_dates = PaymentInfoServiceV2.adjust_rent(payment_info, rent_change2)

            assert_equal(expected_result, payment_dates)
            assert_equal(expected_result, payment_info.payment_dates)
        end

        def test_adjust_rent_with_payment_method_once
            rent = TestUtilsV2.generate_basic_rent_input
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

            payment_info = PaymentInfoServiceV2.build_payment_info(rent)
            payment_dates = PaymentInfoServiceV2.adjust_rent(payment_info, rent_change)

            assert_equal(expected_result, payment_dates)
            assert_equal(expected_result, payment_info.payment_dates)
        end

        def test_adjust_rent_with_payment_method_multiple
            rent = TestUtilsV2.generate_basic_rent_input
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

            payment_info = PaymentInfoServiceV2.build_payment_info(rent)
            PaymentInfoServiceV2.adjust_rent(payment_info, rent_change1)
            payment_dates = PaymentInfoServiceV2.adjust_rent(payment_info, rent_change2)

            assert_equal(expected_result, payment_dates)
            assert_equal(expected_result, payment_info.payment_dates)
        end

        def test_adjust_basic_rent_then_add_payment_method
            rent = TestUtilsV2.generate_basic_rent_input
            rent_change = {
                amount: 1200,
                effective_date: "2024-01-15"
            }

            expected_result = [
                { payment_date: "2023-12-30", amount: 1000, method: "credit_card" },
                { payment_date: "2024-01-30", amount: 1200, method: "credit_card" },
                { payment_date: "2024-02-28", amount: 1200, method: "credit_card" }
            ]

            payment_info = PaymentInfoServiceV2.build_payment_info(rent)
            PaymentInfoServiceV2.adjust_rent(payment_info, rent_change)
            payment_dates = PaymentInfoServiceV2.add_or_change_payment_method(payment_info, "credit_card")

            assert_equal(expected_result, payment_dates)
            assert_equal(expected_result, payment_info.payment_dates)
        end

        def test_add_payment_method_then_adjust_rent
            rent = TestUtilsV2.generate_basic_rent_input
            rent_change = {
                amount: 1200,
                effective_date: "2024-01-15"
            }

            expected_result = [
                { payment_date: "2023-12-30", amount: 1000, method: "credit_card" },
                { payment_date: "2024-01-30", amount: 1200, method: "credit_card" },
                { payment_date: "2024-02-28", amount: 1200, method: "credit_card" }
            ]

            payment_info = PaymentInfoServiceV2.build_payment_info(rent)
            PaymentInfoServiceV2.add_or_change_payment_method(payment_info, "credit_card")
            payment_dates = PaymentInfoServiceV2.adjust_rent(payment_info, rent_change)

            assert_equal(expected_result, payment_dates)
            assert_equal(expected_result, payment_info.payment_dates)
        end

        def test_adjust_date_equal_to_payment_date
            rent = TestUtilsV2.generate_basic_rent_input
            rent_change = {
                amount: 1200,
                effective_date: "2024-02-01"
            }

            expected_result = [
                { payment_date: "2024-01-01", amount: 1000, method: "" },
                { payment_date: "2024-02-01", amount: 1200, method: "" },
                { payment_date: "2024-03-01", amount: 1200, method: "" }
            ]

            payment_info = PaymentInfoServiceV2.build_payment_info(rent)
            payment_dates = PaymentInfoServiceV2.adjust_rent(payment_info, rent_change)

            assert_equal(expected_result, payment_dates)
            assert_equal(expected_result, payment_info.payment_dates)
        end

        def test_advance_rent_with_adjustment
            rent = TestUtilsV2.generate_basic_rent_input
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

            payment_info = PaymentInfoServiceV2.build_payment_info(rent)
            payment_dates = PaymentInfoServiceV2.adjust_rent(payment_info, rent_change)

            assert_equal(expected_result, payment_dates)
            assert_equal(expected_result, payment_info.payment_dates)
        end

    end


    class RentWithMethodTest < Test::Unit::TestCase

        # PROVIDED TEST CASE:
        def test_rent_with_payment_method_credit
            rent = TestUtilsV2.generate_basic_rent_input
            rent[:payment_method] = "credit_card"

            expected_result = [
                { payment_date: "2023-12-30", amount: 1000, method: "credit_card" },
                { payment_date: "2024-01-30", amount: 1000, method: "credit_card" },
                { payment_date: "2024-02-28", amount: 1000, method: "credit_card" }
            ]

            payment_info = PaymentInfoServiceV2.build_payment_info(rent)
            payment_dates = payment_info.payment_dates

            assert_equal(expected_result, payment_dates)
        end

        # CUSTOM TEST CASES:
        def test_rent_with_payment_method_bank
            rent = TestUtilsV2.generate_basic_rent_input
            rent[:payment_method] = "bank_transfer"

            expected_result = [
                { payment_date: "2023-12-29", amount: 1000, method: "bank_transfer" },
                { payment_date: "2024-01-29", amount: 1000, method: "bank_transfer" },
                { payment_date: "2024-02-27", amount: 1000, method: "bank_transfer" }
            ]

            payment_info = PaymentInfoServiceV2.build_payment_info(rent)
            payment_dates = payment_info.payment_dates

            assert_equal(expected_result, payment_dates)
        end

        def test_rent_with_payment_method_instant
            rent = TestUtilsV2.generate_basic_rent_input
            rent[:payment_method] = "instant"

            expected_result = [
                { payment_date: "2024-01-01", amount: 1000, method: "instant" },
                { payment_date: "2024-02-01", amount: 1000, method: "instant" },
                { payment_date: "2024-03-01", amount: 1000, method: "instant" }
            ]

            payment_info = PaymentInfoServiceV2.build_payment_info(rent)
            payment_dates = payment_info.payment_dates

            assert_equal(expected_result, payment_dates)
        end

        def test_add_payment_method_to_basic
            rent = TestUtilsV2.generate_basic_rent_input

            expected_result = [
                { payment_date: "2023-12-29", amount: 1000, method: "bank_transfer" },
                { payment_date: "2024-01-29", amount: 1000, method: "bank_transfer" },
                { payment_date: "2024-02-27", amount: 1000, method: "bank_transfer" }
            ]

            payment_info = PaymentInfoServiceV2.build_payment_info(rent)
            payment_dates = PaymentInfoServiceV2.add_or_change_payment_method(payment_info, "bank_transfer")

            assert_equal(expected_result, payment_dates)
            assert_equal(expected_result, payment_info.payment_dates)
        end

        def test_change_payment_method
            rent = TestUtilsV2.generate_basic_rent_input
            rent[:payment_method] = "bank_transfer"

            expected_result = [
                { payment_date: "2024-01-01", amount: 1000, method: "instant" },
                { payment_date: "2024-02-01", amount: 1000, method: "instant" },
                { payment_date: "2024-03-01", amount: 1000, method: "instant" }
            ]

            payment_info = PaymentInfoServiceV2.build_payment_info(rent)
            payment_dates = PaymentInfoServiceV2.add_or_change_payment_method(payment_info, "instant")

            assert_equal(expected_result, payment_dates)
            assert_equal(expected_result, payment_info.payment_dates)
        end

    end

end
