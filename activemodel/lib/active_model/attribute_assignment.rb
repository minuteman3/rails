require 'active_support/core_ext/hash/keys'

module ActiveModel
  module AttributeAssignment
    include ActiveModel::ForbiddenAttributesProtection

    # Allows you to set all the attributes by passing in a hash of attributes with
    # keys matching the attribute names.
    #
    # If the passed hash responds to <tt>permitted?</tt> method and the return value
    # of this method is +false+ an <tt>ActiveModel::ForbiddenAttributesError</tt>
    # exception is raised.
    #
    #   class Cat
    #     include ActiveModel::AttributeAssignment
    #     attr_accessor :name, :status
    #   end
    #
    #   cat = Cat.new
    #   cat.assign_attributes(name: "Gorby", status: "yawning")
    #   cat.name # => 'Gorby'
    #   cat.status => 'yawning'
    #   cat.assign_attributes(status: "sleeping")
    #   cat.name # => 'Gorby'
    #   cat.status => 'sleeping'
    def assign_attributes(new_attributes)
      if !new_attributes.respond_to?(:stringify_keys)
        raise ArgumentError, "When assigning attributes, you must pass a hash as an argument."
      end
      return if new_attributes.blank?

      attributes = new_attributes.stringify_keys
      _assign_attributes(sanitize_for_mass_assignment(attributes))
    end

    private
    def _assign_attributes(attributes)
      attributes.each do |k, v|
        _assign_attribute(k, v)
      end
    end

    def _assign_attribute(k, v)
      public_send("#{k}=", v)
    rescue NoMethodError
      if respond_to?("#{k}=")
        raise
      else
        raise UnknownAttributeError.new(self, k)
      end
    end

    # Raised when unknown attributes are supplied via mass assignment.
    class UnknownAttributeError < NoMethodError
      attr_reader :record, :attribute

      def initialize(record, attribute)
        @record = record
        @attribute = attribute
        super("unknown attribute '#{attribute}' for #{@record.class}.")
      end
    end
  end
end
