require 'date'
require_relative '../constant/util_constants'
require_relative '../exception/invalid_input_error'


class RentUtils
    class << self

        def validate_rent(rent)
            if !RENT_REQUIRED_FIELDS.all? { |field| rent.include?(field) }
                raise InvalidInputError.new("There is a missing required field in your input.")
            end

            if !rent[:amount].is_a?(Numeric)
                raise InvalidInputError.new("Rent amount should be numerical.")
            end

            if !RENT_FREQUENCY.has_key?(rent[:frequency].to_sym)
                raise InvalidInputError.new("Rent frequency is invalid.")
            end

            if !rent[:payment_method].nil? && !PAYMENT_METHOD.has_key?(rent[:payment_method].to_sym)
                raise InvalidInputError.new("Payment method is invalid.")
            end

            if !rent[:start_date].match(DATE_REGEXP) || !rent[:end_date].match(DATE_REGEXP)
                raise InvalidInputError.new("Format for date/s should follow YYYY-MM-DD.")
            end

            parse_rent(rent)
        end

        def validate_rent_change(rent_change)
            if !RENT_CHANGE_REQUIRED_FIELDS.all? { |field| rent_change.include?(field) }
                raise InvalidInputError.new("There is a missing required field in your input.")
            end

            if !rent_change[:amount].is_a?(Numeric)
                raise InvalidInputError.new("Change amount should be numerical.")
            end

            if !rent_change[:effective_date].match(DATE_REGEXP)
                raise InvalidInputError.new("Format for date/s should follow YYYY-MM-DD.")
            end

            parse_rent_change(rent_change)
        end

        def validate_payment_method(payment_method)
            if !PAYMENT_METHOD.has_key?(payment_method.to_sym)
                raise InvalidInputError.new("Payment method is invalid.")
            end

            payment_method.to_sym
        end

        private

        def parse_rent(rent)
            parsed_rent = rent.dup

            parsed_rent[:frequency] = rent[:frequency].to_sym
            parsed_rent[:start_date] = Date.strptime(rent[:start_date], DATE_FORMAT)
            parsed_rent[:end_date] = Date.strptime(rent[:end_date], DATE_FORMAT)
            parsed_rent[:method] = rent.include?(:payment_method) ? rent[:payment_method].to_sym : :none

            parsed_rent
        end

        def parse_rent_change(rent_change)
            rent_change[:effective_date] = Date.strptime(rent_change[:effective_date], DATE_FORMAT)
            rent_change
        end

    end
end
