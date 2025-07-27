require_relative 'constant/util_constants'
require_relative 'util/rent_utils'


class PaymentInfo

    def initialize(rent)
        @rent = RentUtils.validate_rent(rent)
        @payment_date_keys = []
        @payment_date_map = build_payment_date_map
        @is_adjusted = false
    end

    def get_payment_dates
        payment_dates = []
        @payment_date_keys.each do |current_date|
            values = @payment_date_map[current_date]
            entry = { payment_date: values[:payment_date].to_s }

            if @is_adjusted
                entry[:amount] = values[:amount]
            end

            if not @rent[:method] == :none
                entry[:method] = values[:method].to_s
                entry[:amount] = values[:amount]
            end

            payment_dates.append(entry)
        end

        payment_dates
    end

    def adjust_rent(rent_change)
        rent_change = RentUtils.validate_rent_change(rent_change)

        @payment_date_map.each do |payment, values|
            values[:amount] = rent_change[:amount] if payment >= rent_change[:effective_date]
        end

        @is_adjusted = true
        get_payment_dates
    end

    def add_or_change_payment_method(payment_method)
        @rent[:method] = RentUtils.validate_payment_method(payment_method)
        @payment_date_map = @payment_date_map.map { |k, v| [k, build_method_entry(k, v[:amount])] }.to_h
        get_payment_dates
    end

    private

    def build_payment_date_map
        date_map = {}

        months = RENT_FREQUENCY[@rent[:frequency]][:months]
        days = RENT_FREQUENCY[@rent[:frequency]][:days]
        i = 0
        while (current_date = (@rent[:start_date] >> (i*months)) + (i*days)) < @rent[:end_date]
            date_map[current_date] = build_method_entry(current_date, @rent[:amount])
            @payment_date_keys.append(current_date)
            i += 1
        end

        date_map
    end

    def build_method_entry(base_date, amount)
        {
            payment_date: base_date - PAYMENT_METHOD[@rent[:method]],
            amount: amount,
            method: @rent[:method]
        }
    end

end
