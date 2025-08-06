class PaymentInfoV2

    attr_reader :payment_date_map, :payment_dates

    def initialize(amount, frequency, start_date, end_date, payment_date_map)
        @amount = amount
        @frequency = frequency
        @start_date = start_date
        @end_date = end_date
        @payment_date_map = payment_date_map
        build_payment_dates
    end

    def payment_date_map=(payment_date_map)
        @payment_date_map = payment_date_map
        build_payment_dates
    end

    private

    def build_payment_dates
        @payment_dates = @payment_date_map.map do |k, v|
            {
                payment_date: v[:payment_date].to_s,
                amount: v[:amount],
                method: v[:method] != :none ? v[:method].to_s : nil.to_s
            }
        end
    end

end
