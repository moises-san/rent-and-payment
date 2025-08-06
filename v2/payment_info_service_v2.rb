require_relative 'entity/payment_info_v2'
require_relative 'util/rent_utils_v2'
require_relative 'constant/util_constants_v2'


class PaymentInfoServiceV2

    class << self

        def build_payment_info(rent)
            parsed_rent = RentUtilsV2.parse_rent(rent)
            payment_date_map = build_payment_dates_from_rent(parsed_rent)

            return PaymentInfoV2.new(parsed_rent[:amount], parsed_rent[:frequency],
                    parsed_rent[:start_date], parsed_rent[:end_date],
                    payment_date_map)
        end

        def adjust_rent(payment_info, rent_change)
            parsed_rent_change = RentUtilsV2.parse_rent_change(rent_change)

            new_payment_date_map = payment_info.payment_date_map.map do |base_date, details|
                new_details = details.dup
                new_details[:amount] = parsed_rent_change[:amount] if base_date >= parsed_rent_change[:effective_date]

                [base_date, new_details]
            end.to_h

            payment_info.payment_date_map = new_payment_date_map

            return payment_info.payment_dates
        end

        def add_or_change_payment_method(payment_info, payment_method)
            parsed_payment_method = RentUtilsV2.parse_payment_method(payment_method)

            new_payment_date_map = payment_info.payment_date_map.map do |base_date, details|
                new_details = details.dup
                new_details[:method] = parsed_payment_method
                new_details[:payment_date] = base_date - PAYMENT_METHOD[parsed_payment_method]

                [base_date, new_details]
            end.to_h

            payment_info.payment_date_map = new_payment_date_map

            return payment_info.payment_dates
        end

        private

        def build_payment_dates_from_rent(rent)
            payment_date_map = {}

            months = RENT_FREQUENCY[rent[:frequency]][:months]
            days = RENT_FREQUENCY[rent[:frequency]][:days]
            i = 0
            while (current_date = (rent[:start_date] >> (i*months)) + (i*days)) < rent[:end_date]
                payment_date_map[current_date] = {
                    payment_date: current_date - PAYMENT_METHOD[rent[:payment_method]],
                    amount: rent[:amount],
                    method: rent[:payment_method]
                }

                i += 1
            end

            return payment_date_map
        end

    end

end
