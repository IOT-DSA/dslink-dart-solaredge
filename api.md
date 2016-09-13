 <pre>
-[root](#root)
 |-[Sites](#sites)
 | |-[@Add_Site(siteName, siteId, siteApiKey)](#add_site)
 | |-[SiteNode](#sitenode)
 | | |-[@Remove_Site()](#remove_site)
 | | |-[@Load_Production_Dates()](#load_production_dates)
 | | |-[@Get_Energy_Measurements(dateRange, timeUnit)](#get_energy_measurements)
 | | |-[@Get_Total_Energy(dateRange)](#get_total_energy)
 | | |-[@Get_Detailed_Power(dateRange)](#get_detailed_power)
 | | |-[@Get_Power_Measurements(dateRange)](#get_power_measurements)
 | | |-[@Get_Storage_Data(dateRange)](#get_storage_data)
 | | |-[@Get_Detailed_Energy(dateRange, timeUnit)](#get_detailed_energy)
 | | |-[siteName](#sitename) - string
 | | |-[siteId](#siteid) - number
 | | |-[accountId](#accountid) - number
 | | |-[status](#status) - string
 | | |-[peakPower](#peakpower) - number
 | | |-[currency](#currency) - string
 | | |-[notes](#notes) - string
 | | |-[siteType](#sitetype) - string
 | | |-[installDate](#installdate) - string
 | | |-[location](#location)
 | | | |-[address](#address) - string
 | | | |-[address2](#address2) - string
 | | | |-[city](#city) - string
 | | | |-[state](#state) - string
 | | | |-[zip](#zip) - string
 | | | |-[country](#country) - string
 | | | |-[timeZone](#timezone) - string
 | | |-[alerts](#alerts)
 | | | |-[numAlerts](#numalerts) - number
 | | | |-[alertSev](#alertsev) - string
 | | |-[uris](#uris) - map
 | | |-[publicSettings](#publicsettings)
 | | | |-[pubName](#pubname) - string
 | | | |-[isPublic](#ispublic) - bool
 | | |-[equipment](#equipment)
 | | | |-[count](#count) - number
 | | | |-[EquipmentNode](#equipmentnode)
 | | | | |-[@Get_Inverter_Data(dateRange)](#get_inverter_data)
 | | | | |-[model](#model) - string
 | | | | |-[manufacturer](#manufacturer) - string
 | | | | |-[serial](#serial) - string
 | | | | |-[data](#data)
 | | | | | |-[totPower](#totpower) - number
 | | | | | |-[dcVolt](#dcvolt) - number
 | | | | | |-[groundRes](#groundres) - number
 | | | | | |-[powLimit](#powlimit) - number
 | | | | | |-[totEng](#toteng) - number
 | | | | | |-[temp](#temp) - number
 | | | | | |-[vl1to2](#vl1to2) - number
 | | | | | |-[vl2to3](#vl2to3) - number
 | | | | | |-[vl3to1](#vl3to1) - number
 | | | | | |-[mode](#mode) - string
 | | | | | |-[dataPhase](#dataphase)
 | | | | | | |-[acCur](#accur) - number
 | | | | | | |-[acVolt](#acvolt) - number
 | | | | | | |-[acFreq](#acfreq) - number
 | | | | | | |-[appPow](#apppow) - number
 | | | | | | |-[actPower](#actpower) - number
 | | | | | | |-[reaPow](#reapow) - number
 | | | | | | |-[cosPhi](#cosphi) - number
 | | |-[apiCalls](#apicalls)
 | | | |-[numCalls](#numcalls) - number
 | | | |-[startTime](#starttime) - number
 | | | |-[endTime](#endtime) - number
 | | |-[energyProductionDates](#energyproductiondates)
 | | | |-[productionStart](#productionstart) - string
 | | | |-[productionEnd](#productionend) - string
 | | |-[sensors](#sensors)
 | | | |-[@Get_Sensor_Data(dateRange)](#get_sensor_data)
 | | | |-[@Load_Sensors()](#load_sensors)
 | | | |-[gateway](#gateway)
 | | | | |-[SensorNode](#sensornode)
 | | | | | |-[measurement](#measurement) - string
 | | | | | |-[senseType](#sensetype) - string
 | | |-[Overview](#overview)
 | | | |-[lastUpdateTime](#lastupdatetime) - string
 | | | |-[currentPower](#currentpower) - number
 | | | |-[lifeTimeData](#lifetimedata)
 | | | | |-[energy](#energy) - number
 | | | | |-[revenue](#revenue) - number
 | | | |-[lastYearData](#lastyeardata)
 | | | | |-[energy](#energy) - number
 | | | | |-[revenue](#revenue) - number
 | | | |-[lastMonthData](#lastmonthdata)
 | | | | |-[energy](#energy) - number
 | | | | |-[revenue](#revenue) - number
 | | | |-[lastDayData](#lastdaydata)
 | | | | |-[energy](#energy) - number
 | | | | |-[revenue](#revenue) - number
 </pre>

---

### root  

Root node of the DsLink  

Type: Node   

---

### Sites  

Collection of Solar Edge Sites.  

Type: Node   
Parent: [root](#root)  

---

### Add_Site  

Add a Solar Edge Site to the link.  

Type: Action   
$is: addSiteNode   
Parent: [Sites](#sites)  

Description:  
Adds a site to the link based on the site ID and API key which are generated within Solar Edge interface. The site will appear in the link with the specified name. Action will verify with the remote server that the provided credentials are valid.  

Params:  

Name | Type | Description
--- | --- | ---
siteName | `string` | Site name to appear in the link.
siteId | `number` | Site ID generated from the remote Solar Edge system.
siteApiKey | `string` | API Key generated from the remote Solar Edge system.

Return type: values   
Columns:  

Name | Type | Description
--- | --- | ---
success | `bool` | Success is true on success, false on failure. 
message | `string` | Message is Success! on success, and an error message on failure. 

---

### SiteNode  

SiteNode is the remote Solar Edge site.  

Type: Node   
Parent: [Sites](#sites)  

Description:  
The node manages equipment located at the site, as well as the number of API calls this site makes to the remote Solar Edge server (as they are limited by the Solar Edge systems). SiteNode will load any connected equipment on initialization.  


---

### Remove_Site  

Remove site from the link.  

Type: Action   
$is: removeSiteNode   
Parent: [SiteNode](#sitenode)  
Return type: values   
Columns:  

Name | Type | Description
--- | --- | ---
success | `bool` | Success returns true on success; false on failure. 
message | `string` | Message returns Success! on success. 

---

### Load_Production_Dates  

Populate the Production Date values on the SiteNode  

Type: Action   
$is: loadProductionDates   
Parent: [SiteNode](#sitenode)  

Description:  
Load Production Dates will query the remote Solar Edge API for the production dates for the site and populate the nodes with the values.  

Return type: values   
Columns:  

Name | Type | Description
--- | --- | ---
success | `bool` | Success is true on success; false on failure. 
message | `string` | Message is Success! on success, and returns an error message on failure. 

---

### Get_Energy_Measurements  

Get Energy Measurements retrieves the sites energy measurements.  

Type: Action   
$is: getEnergyMeasurements   
Parent: [SiteNode](#sitenode)  

Description:  
Get Energy Measurements will return measurements for a given time range over a specified time period. Action returns a list of measurements at the date time with the value and measurement unit. It will verify the time range is valid and the time period is permitted with the specified time range. *When using time period of 1 day, the time range is limited to one year.* *When using a time period of Quarter_Of_An_Hour or Hour, time range is limited to one 1 month.*  

Params:  

Name | Type | Description
--- | --- | ---
dateRange | `string` | Date range for the period of time to retrieve the energy measurements. Should be in the format MM-DD-YYYY HH:mm:SS/MM-DD-YYYY HH:mm:SS
timeUnit | `enum[Quarter_Of_An_Hour,Hour,Day,Week,Month,Year]` | Time unit is interval period from which measurements over the dateRange should be provided.

Return type: table   
Columns:  

Name | Type | Description
--- | --- | ---
date | `string` | Date Time of the measurement. 
value | `number` | Value of the measurement. 
energyUnity | `string` | Unit of the measurement value. 

---

### Get_Total_Energy  

Gets total energy produced over specified time period.  

Type: Action   
$is: getTotalEnergy   
Parent: [SiteNode](#sitenode)  

Description:  
Get Total Energy retrieves the total energy produced over the specified time period. It will validate that the time range is valid and return 0 values if not valid.  

Params:  

Name | Type | Description
--- | --- | ---
dateRange | `string` | Date range for the period of time to retrieve the energy produced. Should be in the format MM-DD-YYYY HH:mm:SS/MM-DD-YYYY HH:mm:SS

Return type: values   
Columns:  

Name | Type | Description
--- | --- | ---
value | `number` | Value is the total energy produced. 
energyUnit | `string` | Energy unit of the energy produced value. 

---

### Get_Detailed_Power  

Get Detailed power measurements from meters.  

Type: Action   
$is: getDetailedPower   
Parent: [SiteNode](#sitenode)  

Description:  
Get Detailed Power retrieves measurements for consumption, production and other power sources over the specified date range. The action is limited to a 1 month period of measurements. It will verify the date range provided. If the action fails it will return an empty list.  

Params:  

Name | Type | Description
--- | --- | ---
dateRange | `string` | Date range for the period of time to retrieve the power measurements. Should be in the format MM-DD-YYYY HH:mm:SS/MM-DD-YYYY HH:mm:SS

Return type: table   
Columns:  

Name | Type | Description
--- | --- | ---
date | `string` | Date time of the power measurement. 
type | `string` | Type of power measurement. (Eg. consumption, production) 
value | `number` | Value of the power measurement. 
energyUnit | `Energy` | Unity of the power measurement value. 

---

### Get_Power_Measurements  

Get power measurements in 15 minute resolution.  

Type: Action   
$is: getSitePower   
Parent: [SiteNode](#sitenode)  

Description:  
Get Power Measurements returns the site's power measurements for the specified date range in 15 minute intervals. This action is limited to a date range of 1 month. It will verify the specified date range and return an empty list on failure.  

Params:  

Name | Type | Description
--- | --- | ---
dateRange | `string` | Date range for the period of time to retrieve the power measurements. Should be in the format MM-DD-YYYY HH:mm:SS/MM-DD-YYYY HH:mm:SS

Return type: table   
Columns:  

Name | Type | Description
--- | --- | ---
date | `string` | Date time of the power measurement. 
value | `number` | Value of the power measurement. 
energyUnit | `Energy` | Unit of the power measurement value. 

---

### Get_Storage_Data  

Get detailed storage information from batteries.  

Type: Action   
$is: getStorageData   
Parent: [SiteNode](#sitenode)  

Description:  
Get Storage Data will retrieve the current state of the batteries connected to the site over the specified time range. It will verify the date range is valid. If the request fails, it returns an empty list.  

Params:  

Name | Type | Description
--- | --- | ---
dateRange | `string` | Date range for the period of time to retrieve the battery usage. Should be in the format MM-DD-YYYY HH:mm:SS/MM-DD-YYYY HH:mm:SS

Return type: table   
Columns:  

Name | Type | Description
--- | --- | ---
namePlate | `number` | The nameplate capacity of the battery. 
serialNumber | `string` | Serial number of the battery. 
timeStamp | `string` | Timestamp of the data. 
power | `number` | Positive number indicates the battery is charging. negative number indicates the battery is discharging. 
lifeTimeEnergyCharged | `number` | The lifetime energy charged into the battery in Wh. 
batteryState | `string` | String representation of the Battery state. May be one of: Invalid, Standby, Thermal Management, Enabled, Fault 

---

### Get_Detailed_Energy  

Get detailed energy produced over date range in specified intervals.  

Type: Action   
$is: getDetailedEnergy   
Parent: [SiteNode](#sitenode)  

Description:  
Get Detailed Energy returns the energy usage over the specified date range at given intervals. This will provide production and consumption values at each time range over the specified period. *Limited to 1 year time range with a time unit interval of 1 day. Limited to 1 month time range when using a time unit interval of Quarter_Of_An_Hour or Hour* Lower resolutions (week, month and year) have no time range limitation.  

Params:  

Name | Type | Description
--- | --- | ---
dateRange | `string` | Date range for the period of time to retrieve the energy usage. Should be in the format MM-DD-YYYY HH:mm:SS/MM-DD-YYYY HH:mm:SS
timeUnit | `enum[Quarter_Of_An_Hour,Hour,Day,Week,Month,Year]` | Time Unit is the interval over which the energy usage should be displayed.

Return type: table   
Columns:  

Name | Type | Description
--- | --- | ---
date | `string` | Date time of the measurement value. 
type | `string` | Type of energy usage (eg. consumption, production) 
value | `number` | Value of the energy usage. 
energyUnit | `string` | Unit of measurement for the energy usage. 

---

### siteName  

Site name specified by the remote server.  

Type: Node   
Parent: [SiteNode](#sitenode)  
Value Type: `string`  
Writable: `never`  

---

### siteId  

Site id specified by the remote server.  

Type: Node   
Parent: [SiteNode](#sitenode)  
Value Type: `number`  
Writable: `never`  

---

### accountId  

Account ID which the site is associated with on the remote server.  

Type: Node   
Parent: [SiteNode](#sitenode)  
Value Type: `number`  
Writable: `never`  

---

### status  

Status is the current commissioning status of the site.  

Type: Node   
Parent: [SiteNode](#sitenode)  

Description:  
Status may be either Active, or Pending Communication if the site has been added to the remote Solar Edge system but has not yet communicated back to the remote server.  

Value Type: `string`  
Writable: `never`  

---

### peakPower  

Peak power is the site's peak power output.  

Type: Node   
Parent: [SiteNode](#sitenode)  
Value Type: `number`  
Writable: `never`  

---

### currency  

Currency is the local currency used at the site.  

Type: Node   
Parent: [SiteNode](#sitenode)  
Value Type: `string`  
Writable: `never`  

---

### notes  

Note left after the setup of the site in the remote Solr Edge server.  

Type: Node   
Parent: [SiteNode](#sitenode)  
Value Type: `string`  
Writable: `never`  

---

### siteType  

Site Type is the type of equpiment at the site.  

Type: Node   
Parent: [SiteNode](#sitenode)  

Description:  
Site Type may be Optimizers and Inverters, Safety and monitoring interface, or Monitoring combiner boxes.  

Value Type: `string`  
Writable: `never`  

---

### installDate  

Installation date converted to an ISO8601 string.  

Type: Node   
Parent: [SiteNode](#sitenode)  
Value Type: `string`  
Writable: `never`  

---

### location  

Collection of location related values.  

Type: Node   
Parent: [SiteNode](#sitenode)  

---

### address  

Street address line one.  

Type: Node   
Parent: [location](#location)  
Value Type: `string`  
Writable: `never`  

---

### address2  

Stress address line two.  

Type: Node   
Parent: [location](#location)  
Value Type: `string`  
Writable: `never`  

---

### city  

City name  

Type: Node   
Parent: [location](#location)  
Value Type: `string`  
Writable: `never`  

---

### state  

State name  

Type: Node   
Parent: [location](#location)  
Value Type: `string`  
Writable: `never`  

---

### zip  

Zip code  

Type: Node   
Parent: [location](#location)  
Value Type: `string`  
Writable: `never`  

---

### country  

Country name  

Type: Node   
Parent: [location](#location)  
Value Type: `string`  
Writable: `never`  

---

### timeZone  

Time zone abbreviation.  

Type: Node   
Parent: [location](#location)  
Value Type: `string`  
Writable: `never`  

---

### alerts  

Alerts is a collection of alert values.  

Type: Node   
Parent: [SiteNode](#sitenode)  

---

### numAlerts  

Number of alerts for this site.  

Type: Node   
Parent: [alerts](#alerts)  
Value Type: `number`  
Writable: `never`  

---

### alertSev  

Highest severity of alerts this site has.  

Type: Node   
Parent: [alerts](#alerts)  
Value Type: `string`  
Writable: `never`  

---

### uris  

Miscellaneous URIs related to this site, such as logo.  

Type: Node   
Parent: [SiteNode](#sitenode)  
Value Type: `map`  
Writable: `never`  

---

### publicSettings  

Collection of values related to public settings.  

Type: Node   
Parent: [SiteNode](#sitenode)  

---

### pubName  

Publicly visible site name.  

Type: Node   
Parent: [publicSettings](#publicsettings)  
Value Type: `string`  
Writable: `never`  

---

### isPublic  

Is the site is publicly visible or not.  

Type: Node   
Parent: [publicSettings](#publicsettings)  
Value Type: `bool`  
Writable: `never`  

---

### equipment  

Collection of equipment at the site.  

Type: Node   
Parent: [SiteNode](#sitenode)  

---

### count  

Total count of equipment at the site.  

Type: Node   
Parent: [equipment](#equipment)  
Value Type: `number`  
Writable: `never`  

---

### EquipmentNode  

Collection of equipment values.  

Type: Node   
$is: equipmentNode   
Parent: [equipment](#equipment)  

Description:  
Equipment values for a specific piece of equipment connected to a site. Some equipment may be an inverter which has additional data. The path will be equip_## where ## is the index number of the equipment in the list. The display name will be the specific equipment name from the remote server.  


---

### Get_Inverter_Data  

Retrieve inverter data for the inverter over a specified date range.  

Type: Action   
$is: getInverterData   
Parent: [EquipmentNode](#equipmentnode)  

Description:  
Get Inverter Data returns inverter data for a date range no greater than one week. If greater than one week or the request fails then the action returns with an empty list. This action is only available on equipment which is an inverter.  

Params:  

Name | Type | Description
--- | --- | ---
dateRange | `string` | Date range for the period of time to retrieve the Inverter Data. Should be in the format MM-DD-YYYY HH:mm:SS/MM-DD-YYYY HH:mm:SS

Return type: table   
Columns:  

Name | Type | Description
--- | --- | ---
date | `string` | Date Time the inverter data was recorder. 
totalPower | `number` | Total active power. 
dcVoltage | `number` | DC Voltage. 
groundResistance | `number` | Total ground resistance. 
powerLimit | `number` | Power limit percentage. 
totalEnergy | `number` | Total lifetime energy. 
phases | `array` | List of maps of phase specific data 

---

### model  

Equipment model number.  

Type: Node   
Parent: [EquipmentNode](#equipmentnode)  
Value Type: `string`  
Writable: `never`  

---

### manufacturer  

The equipment manufacturer.  

Type: Node   
Parent: [EquipmentNode](#equipmentnode)  
Value Type: `string`  
Writable: `never`  

---

### serial  

Equipment's short serial number  

Type: Node   
Parent: [EquipmentNode](#equipmentnode)  
Value Type: `string`  
Writable: `never`  

---

### data  

Collection of data used by inverter equipment.  

Type: Node   
Parent: [EquipmentNode](#equipmentnode)  

---

### totPower  

Total active power  

Type: Node   
$is: inverterValueNode   
Parent: [data](#data)  
Value Type: `number`  
Writable: `never`  

---

### dcVolt  

DC Voltage  

Type: Node   
$is: inverterValueNode   
Parent: [data](#data)  
Value Type: `number`  
Writable: `never`  

---

### groundRes  

Ground fault resistance  

Type: Node   
$is: inverterValueNode   
Parent: [data](#data)  
Value Type: `number`  
Writable: `never`  

---

### powLimit  

Power limit percentage  

Type: Node   
$is: inverterValueNode   
Parent: [data](#data)  
Value Type: `number`  
Writable: `never`  

---

### totEng  

Total Lifetime energy.  

Type: Node   
$is: inverterValueNode   
Parent: [data](#data)  
Value Type: `number`  
Writable: `never`  

---

### temp  

Temperature of the device.  

Type: Node   
$is: inverterValueNode   
Parent: [data](#data)  
Value Type: `number`  
Writable: `never`  

---

### vl1to2  

vL1 to 2  

Type: Node   
$is: inverterValueNode   
Parent: [data](#data)  
Value Type: `number`  
Writable: `never`  

---

### vl2to3  

vL2 to 3  

Type: Node   
$is: inverterValueNode   
Parent: [data](#data)  
Value Type: `number`  
Writable: `never`  

---

### vl3to1  

vL3 to 1  

Type: Node   
$is: inverterValueNode   
Parent: [data](#data)  
Value Type: `number`  
Writable: `never`  

---

### mode  

Inverter mode  

Type: Node   
Parent: [data](#data)  
Value Type: `string`  
Writable: `never`  

---

### dataPhase  

Phase data per inverter.  

Type: Node   
Parent: [data](#data)  

---

### acCur  

AC Current  

Type: Node   
$is: inverterValueNode   
Parent: [dataPhase](#dataphase)  
Value Type: `number`  
Writable: `never`  

---

### acVolt  

AC Voltage  

Type: Node   
$is: inverterValueNode   
Parent: [dataPhase](#dataphase)  
Value Type: `number`  
Writable: `never`  

---

### acFreq  

AC Frequency  

Type: Node   
$is: inverterValueNode   
Parent: [dataPhase](#dataphase)  
Value Type: `number`  
Writable: `never`  

---

### appPow  

Apparent Power  

Type: Node   
$is: inverterValueNode   
Parent: [dataPhase](#dataphase)  
Value Type: `number`  
Writable: `never`  

---

### actPower  

Active Power  

Type: Node   
$is: inverterValueNode   
Parent: [dataPhase](#dataphase)  
Value Type: `number`  
Writable: `never`  

---

### reaPow  

Reactive Power  

Type: Node   
$is: inverterValueNode   
Parent: [dataPhase](#dataphase)  
Value Type: `number`  
Writable: `never`  

---

### cosPhi  

Cos Phi  

Type: Node   
$is: inverterValueNode   
Parent: [dataPhase](#dataphase)  
Value Type: `number`  
Writable: `never`  

---

### apiCalls  

Collection of values related to API calls to the remote Solar Edge server  

Type: Node   
Parent: [SiteNode](#sitenode)  

---

### numCalls  

Number of calls made to the API server in the last 24 hours.  

Type: Node   
Parent: [apiCalls](#apicalls)  
Value Type: `number`  
Writable: `never`  

---

### startTime  

Site local start time of when to start making API calls.  

Type: Node   
$is: apiCallTime   
Parent: [apiCalls](#apicalls)  

Description:  
The local start time of when API calls are being sent. Defaults to 05h00. This helps prevent API calls during times when there will be little to no change in the remote data.  

Value Type: `number`  
Writable: `write`  

---

### endTime  

The local stop to of when API calls are being sent. Defaults to 21h00. This helps prevent API calls during times when there will be little to no change in the remote data.  

Type: Node   
$is: apiCallTime   
Parent: [apiCalls](#apicalls)  
Value Type: `number`  
Writable: `write`  

---

### energyProductionDates  

Collection of values related to energy production dates for the site.  

Type: Node   
Parent: [SiteNode](#sitenode)  

---

### productionStart  

Production start is the date the site started to produce energy.  

Type: Node   
Parent: [energyProductionDates](#energyproductiondates)  
Value Type: `string`  
Writable: `never`  

---

### productionEnd  

Production End is the last date the site produced energy.  

Type: Node   
Parent: [energyProductionDates](#energyproductiondates)  
Value Type: `string`  
Writable: `never`  

---

### sensors  

Collection of sensors located at the site.  

Type: Node   
Parent: [SiteNode](#sitenode)  

---

### Get_Sensor_Data  

Retrieves data which has been logged by various sensors.  

Type: Action   
$is: getSensorData   
Parent: [sensors](#sensors)  

Description:  
Action will get the sensor data for all connected sensors on each gateway. It will verify that the date range is a valid date range, and return an empty list on failure. On success it returns a list of mapped data.  

Params:  

Name | Type | Description
--- | --- | ---
dateRange | `string` | Date range in the format of MM-DD-YYYY HH:mm:SS/MM-DD-YYYY HH:mm:SS

Return type: table   
Columns:  

Name | Type | Description
--- | --- | ---
connectedTo | `string` | Connected to is the gateway the sensor is connected to. 
date | `string` | Date is a Date time string of when the sensor data was recorded. 
measurement | `string` | Measurement is the measurement name that the value represents. 
value | `number` | Value is the recorded data point from the sensor. 

---

### Load_Sensors  

Retreives a list of Gateways and connected Sensors.  

Type: Action   
$is: loadSensorsNode   
Parent: [sensors](#sensors)  

Description:  
Queries the remote Solar Edge system for a list of gateways and their connected sensors.  

Return type: values   
Columns:  

Name | Type | Description
--- | --- | ---
success | `bool` | Success returns true on success; false on failure. 
message | `string` | Message returns Success! on success, and an error message on failure. 

---

### gateway  

Gateway is a connection point for multiple sensors.  

Type: Node   
Parent: [sensors](#sensors)  

Description:  
Gateway is specified by the remote Solar Edge system. It is a collection of sensors which connect to it to connect in turn to the remote Solar Edge system. Path and name are provided by the remote Solar Edge system.  


---

### SensorNode  

Collection of data for Sensors located at the site.  

Type: Node   
$is: sensorNode   
Parent: [gateway](#gateway)  

Description:  
Sensor's are connected to gateways which only maintain the connection from the site to the sensor. Sensors will have the path and name provided by the remote Solar Edge system.  


---

### measurement  

Measurement name that the sensor will poll for.  

Type: Node   
Parent: [SensorNode](#sensornode)  
Value Type: `string`  
Writable: `never`  

---

### senseType  

The type of measurement that measurement represents.  

Type: Node   
Parent: [SensorNode](#sensornode)  
Value Type: `string`  
Writable: `never`  

---

### Overview  

Collection of Site overview values.  

Type: Node   
$is: overviewNode   
Parent: [SiteNode](#sitenode)  

Description:  
Collection of site overview values. If any of the values has a subscription, then the OverviewNode will send an API request once every 15 minutes to retrieve updated values.  


---

### lastUpdateTime  

Last time overview values were updated.  

Type: Node   
$is: overviewValue   
Parent: [Overview](#overview)  
Value Type: `string`  
Writable: `never`  

---

### currentPower  

Current power output of the site.  

Type: Node   
$is: overviewValue   
Parent: [Overview](#overview)  
Value Type: `number`  
Writable: `never`  

---

### lifeTimeData  

Collection of Site lifetime data values.  

Type: Node   
$is: energyRevenueNode   
Parent: [Overview](#overview)  

---

### energy  

Lifetime energy generated.  

Type: Node   
$is: overviewValue   
Parent: [lifeTimeData](#lifetimedata)  
Value Type: `number`  
Writable: `never`  

---

### revenue  

Life time revenue generated.  

Type: Node   
$is: overviewValue   
Parent: [lifeTimeData](#lifetimedata)  
Value Type: `number`  
Writable: `never`  

---

### lastYearData  

Collection of Site data values over the last year.  

Type: Node   
$is: energyRevenueNode   
Parent: [Overview](#overview)  

---

### energy  

Last year energy generated.  

Type: Node   
$is: overviewValue   
Parent: [lastYearData](#lastyeardata)  
Value Type: `number`  
Writable: `never`  

---

### revenue  

Last Year revenue generated.  

Type: Node   
$is: overviewValue   
Parent: [lastYearData](#lastyeardata)  
Value Type: `number`  
Writable: `never`  

---

### lastMonthData  

Collection of Site data values over the last month.  

Type: Node   
$is: energyRevenueNode   
Parent: [Overview](#overview)  

---

### energy  

Last Month energy generated.  

Type: Node   
$is: overviewValue   
Parent: [lastMonthData](#lastmonthdata)  
Value Type: `number`  
Writable: `never`  

---

### revenue  

Last Month revenue generated.  

Type: Node   
$is: overviewValue   
Parent: [lastMonthData](#lastmonthdata)  
Value Type: `number`  
Writable: `never`  

---

### lastDayData  

Collection of Site data values over the last day.  

Type: Node   
$is: energyRevenueNode   
Parent: [Overview](#overview)  

---

### energy  

Last day energy generated.  

Type: Node   
$is: overviewValue   
Parent: [lastDayData](#lastdaydata)  
Value Type: `number`  
Writable: `never`  

---

### revenue  

Last Day revenue generated.  

Type: Node   
$is: overviewValue   
Parent: [lastDayData](#lastdaydata)  
Value Type: `number`  
Writable: `never`  

---

