macro class_property(*property_names)
  {% for property_name in property_names %}
    def self.{{ property_name }}
      @@{{ property_name }}
    end

    def self.{{ property_name }}=({{ property_name }})
      @@{{ property_name }} = {{ property_name }}
    end
  {% end %}
end
