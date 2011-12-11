## route list
http://webservices.nextbus.com/service/publicXMLFeed?command=routeList&a=sf-muni

## stop list for a route
http://webservices.nextbus.com/service/publicXMLFeed?command=routeConfig&a=sf-muni&r=N

## single route+stop+direction prediction
http://webservices.nextbus.com/service/publicXMLFeed?command=predictions&a=sf-muni&r=N&s=5205&useShortTitles=true

## multiple route+stop+direction predictions
http://webservices.nextbus.com/service/publicXMLFeed?command=predictionsForMultiStops&a=sf-muni&stops=N|null|6997&stops=N|null|3909


## for my commutes
### 9
    <stop tag="5639" title="Market St & 2nd St" lat="37.7893499" lon="-122.40131" stopId="15639"/>
    <stop tag="6028" title="Potrero Ave & 17th St" lat="37.76474" lon="-122.40735" stopId="16028"/>

### 9L
    <stop tag="5639" title="Market St & 2nd St" lat="37.7893499" lon="-122.40131" stopId="15639"/>
    <stop tag="6026" title="Potrero Ave & 16th St" lat="37.7660299" lon="-122.40747" stopId="16026"/>


http://webservices.nextbus.com/service/publicXMLFeed?command=predictionsForMultiStops&a=sf-muni&stops=9|null|5639&stops=9L|null|5639
http://webservices.nextbus.com/service/publicXMLFeed?command=predictionsForMultiStops&a=sf-muni&stops=9|null|6028&stops=9L|null|6026


## google_transit/trips.txt
service_id,---,tripTag
1900,2,4454067

## google_transit/stop_times.txt
tripTag,arrivalTime,departureTime,stopTag,sequence
4454067,24:32:33,24:32:33,6028,43, , , ,
