
### Homeassistant คำนวณค่าไฟฟ้า ของการไฟฟ้าส่วนภูมิภาค

```yaml
sensor:
  - platform: rest
    name: "p150"
    resource: "https://raw.githubusercontent.com/iaunn/thailand-electric-rate/master/thailand_electric_rate.json"
    value_template: "{{ value_json.grid_150 }}"
    unit_of_measurement: "THB"
    scan_interval: 3600  # ปรับตามความเหมาะสม (หน่วยเป็นวินาที)

  - platform: rest
    name: "p250"
    resource: "https://raw.githubusercontent.com/iaunn/thailand-electric-rate/master/thailand_electric_rate.json"
    value_template: "{{ value_json.grid_250 }}"
    unit_of_measurement: "THB"
    scan_interval: 3600  # ปรับตามความเหมาะสม (หน่วยเป็นวินาที)

  - platform: rest
    name: "p400"
    resource: "https://raw.githubusercontent.com/iaunn/thailand-electric-rate/master/thailand_electric_rate.json"
    value_template: "{{ value_json.grid_400 }}"
    unit_of_measurement: "THB"
    scan_interval: 3600  # ปรับตามความเหมาะสม (หน่วยเป็นวินาที)

  - platform: rest
    name: "ft"
    resource: "https://raw.githubusercontent.com/iaunn/thailand-electric-rate/master/thailand_electric_rate.json"
    value_template: "{{ value_json.ft }}"
    unit_of_measurement: "THB/kWh"
    scan_interval: 3600  # ปรับตามความเหมาะสม (หน่วยเป็นวินาที)

  - platform: rest
    name: "service"
    resource: "https://raw.githubusercontent.com/iaunn/thailand-electric-rate/master/thailand_electric_rate.json"
    value_template: "{{ value_json.service }}"
    unit_of_measurement: "THB"
    scan_interval: 3600  # ปรับตามความเหมาะสม (หน่วยเป็นวินาที)

  - platform: template
    sensors:
      electricity_cost:
        friendly_name: "Electricity Cost"
        unit_of_measurement: "THB"
        value_template: >
          {% set usage = states('sensor.monthly_energy') | float %}
          {% set rate_150 = states('sensor.p150') | float %}
          {% set rate_250 = states('sensor.p250') | float %}
          {% set rate_400 = states('sensor.p400') | float %}
          {% set ft = states('sensor.ft') | float %}
          {% set service_charge = states('sensor.service') | float %}
          
          {% if usage <= 150 %}
            {% set cost = usage * rate_150 %}
          {% elif usage <= 400 %}
            {% set cost = (150 * rate_150) + ((usage - 150) * rate_250) %}
          {% else %}
            {% set cost = (150 * rate_150) + (250 * rate_250) + ((usage - 400) * rate_400) %}
          {% endif %}
          
          {{ (cost + (usage * ft)) * 1.07 + service_charge }}

utility_meter:
  monthly_energy:
    source: sensor.overall_used
    cycle: monthly
```

- https://www.pea.co.th/Portals/0/demand_response/ElectricityReconsiderNov61.pdf?ver=2019-01-25-100804-110
- https://www.pea.co.th/%E0%B8%82%E0%B9%88%E0%B8%B2%E0%B8%A7%E0%B8%AA%E0%B8%B2%E0%B8%A3%E0%B8%9B%E0%B8%A3%E0%B8%B0%E0%B8%81%E0%B8%B2%E0%B8%A8/%E0%B8%82%E0%B9%88%E0%B8%B2%E0%B8%A7%E0%B8%9B%E0%B8%A3%E0%B8%B0%E0%B8%8A%E0%B8%B2%E0%B8%AA%E0%B8%B1%E0%B8%A1%E0%B8%9E%E0%B8%B1%E0%B8%99%E0%B8%98%E0%B9%8C/ArtMID/542/ArticleID/152365/%E0%B8%9B%E0%B8%A3%E0%B8%B1%E0%B8%9A%E0%B8%A5%E0%B8%94%E0%B8%AD%E0%B8%B1%E0%B8%95%E0%B8%A3%E0%B8%B2%E0%B8%84%E0%B9%88%E0%B8%B2%E0%B8%9A%E0%B8%A3%E0%B8%B4%E0%B8%81%E0%B8%B2%E0%B8%A3%E0%B8%A3%E0%B8%B2%E0%B8%A2%E0%B9%80%E0%B8%94%E0%B8%B7%E0%B8%AD%E0%B8%99-%E0%B8%95%E0%B8%B1%E0%B9%89%E0%B8%87%E0%B9%81%E0%B8%95%E0%B9%88%E0%B8%84%E0%B9%88%E0%B8%B2%E0%B9%84%E0%B8%9F%E0%B8%9F%E0%B9%89%E0%B8%B2%E0%B8%9B%E0%B8%A3%E0%B8%B0%E0%B8%88%E0%B8%B3%E0%B9%80%E0%B8%94%E0%B8%B7%E0%B8%AD%E0%B8%99-%E0%B8%A1%E0%B8%81%E0%B8%A3%E0%B8%B2%E0%B8%84%E0%B8%A1-2566-%E0%B9%80%E0%B8%9B%E0%B9%87%E0%B8%99%E0%B8%95%E0%B9%89%E0%B8%99%E0%B9%84%E0%B8%9B
