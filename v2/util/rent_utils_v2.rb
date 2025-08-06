require 'date'
require_relative '../constant/util_constants_v2'


class RentUtilsV2
    class << self

        def parse_rent(rent)
            return {
                amount: rent[:amount],
                frequency: rent[:frequency].to_sym,
                start_date: Date.strptime(rent[:start_date], DATE_FORMAT),
                end_date: Date.strptime(rent[:end_date], DATE_FORMAT),
                payment_method: rent.include?(:payment_method) ? rent[:payment_method].to_sym : :none
            }
        end

        def parse_rent_change(rent_change)
            return {
                amount: rent_change[:amount],
                effective_date: Date.strptime(rent_change[:effective_date], DATE_FORMAT)
            }
        end

        def parse_payment_method(payment_method)
            return payment_method.to_sym
        end

    end
end
