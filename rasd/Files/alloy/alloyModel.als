sig Username{}

sig Password{}

/*
sig Pec{
	content: one String
}
*/

sig Registration{
	username: one Username,
	password: one Password
}

abstract sig Customer{
	registration: one Registration
}

sig User extends Customer{}

sig Authority extends Customer{
	city: one City
}

sig City{
	streets: some Street,
	authority: lone Authority
}

sig Street{
	streetName: one StreetName,
	positions: some Position,
	reports: set Report,
	accidents: set Accident,
	suggestedInterventions: set Intervention,
	status : one StreetStatus
}

abstract sig StreetStatus{}

one sig Safe extends StreetStatus{}

one sig Unsafe extends StreetStatus{}

sig StreetName{
}

sig Position{
	street : one Street
}

sig Date{}

sig Time{}

sig ViolationType{
	interventions: set Intervention
}

sig VehicleType{}

sig Intervention{}

sig Plate{}

sig Report{
	user: one User,
	position: one Position,
	violationType: one ViolationType,
	vehicleType: one VehicleType,
	date : one Date,
	time: one Time,
	plate : lone Plate,
}

sig StoredReport{
	report : one Report,
	plate : one Plate,
	streetName : one StreetName,
	status : one ReportStatus
}

fact CorrectStreetNameInReport{
	all sr: StoredReport | sr.streetName in 
		sr.report.position.street.streetName
}

abstract sig ReportStatus{}

one sig Read extends ReportStatus{}

one sig Unread extends ReportStatus{}

sig AccidentType{
	interventions: set Intervention
}

sig Accident{
	type : one AccidentType,
	street: one Street
}

--///////////////////////////////////////////////////////////////////////////////////////////////////////////
--STREETS
--///////////////////////////////////////////////////////////////////////////////////////////////////////////

fact NoStreetWithoutCity{
	all s: Street | one c:City | s in c.streets
}

fact NoStreetsWithSameNameInCity{
	all s1, s2:Street | ((some c:City| s1 in c.streets and s2 in c.streets) and 
		not(s1=s2)) implies not(s1.streetName = s2.streetName)
}

fact NoStreetNameWithoutStreet{
	all sn: StreetName | some s:Street | sn in s.streetName
}

fact PositionOnlyInOneStreet{
	no disj s1, s2: Street | s1.positions & s2.positions not = none
}

fact NoPositionWithoutStreet{
	all p:Position | some s:Street | p in s.positions
}

fact PositionStreetLinked{
	all s:Street, p:Position | p in s.positions implies s in p.street
}

fact ReportStreetLinked{
	all s:Street, r:Report | r in s.reports iff s in r.position.street
}

fact AccidentStreetLinked{
	all s:Street, a: Accident | a in s.accidents iff s in a.street
}

--///////////////////////////////////////////////////////////////////////////////////////////////////////////
--INTERVENTIONS
--///////////////////////////////////////////////////////////////////////////////////////////////////////////

--an intervention is suggested for a street iff the number of reports in 
--that street that contain violation types linked to that intervention
--is greater than 0
fact InterventionSuggestedThreshold{
	all s: Street, i:Intervention| (i in s.suggestedInterventions iff  
		(#getReportsFromInterventionAndStreet[i, s] > 0 or
		#getAccidentsFromInterventionAndStreet[i, s] > 0))
}

fun getReportsFromInterventionAndStreet[i : Intervention, s : Street] : set Report{
	{
		r : Report | i in r.violationType.interventions and r in s.reports
	}
}

fun getAccidentsFromInterventionAndStreet[i: Intervention, s : Street] : set Accident{
	{
		a : Accident | i in a.type.interventions and a in s.accidents
	}
}


--///////////////////////////////////////////////////////////////////////////////////////////////////////////
--UNSAFE STREETS
--///////////////////////////////////////////////////////////////////////////////////////////////////////////

--a street is considered unsafe iff 
--the number of total accidents in that street is greater than 1 OR
--if the number of total violations in that street is greater than 1

fact UnsafeStreetThreshold{
	all s: Street | s.status = Unsafe iff (
		#s.reports > 1 or  
		#s.accidents > 1
	)
}

--///////////////////////////////////////////////////////////////////////////////////////////////////////////
--REGISTRATION
--///////////////////////////////////////////////////////////////////////////////////////////////////////////

--every Customer has a different Registration
/*
fact UniqueRegistration{
	all disj c1,c2: Customer | not (c1.registration = c2.registration)
}
*/

fact NoRegistrationWithoutCustomer{
	all r: Registration | one c:Customer | r in c.registration
}

fact NoUsernameWithoutRegistration{
	all u:Username | some r:Registration | u in r.username
}

fact NoPasswordWithoutRegistration{
	all p: Password | some r: Registration | p in r.password
}

fact UniqueUsernames{
	no disj r1,r2: Registration| r1.username = r2.username
}

fact CityAuthorityLink{
	all c:City, a:Authority | a in c.authority iff c in a.city
}

--///////////////////////////////////////////////////////////////////////////////////////////////////////////
--REQUESTS AND RESULT
--///////////////////////////////////////////////////////////////////////////////////////////////////////////

abstract sig Request{
	customer : one Customer
}

sig ReportsRequest extends Request{
	
}{
	customer = Authority
}

sig MostViolationsRequest extends Request{}

sig DangerousVehiclesRequest extends Request{}

sig UnsafeStreetsRequest extends Request{}

sig InterventionsRequest extends Request{}


--///////////////////////////////////////////////////////////////////////////////////////////////////////////
--PREDICATES AND COMMANDS
--///////////////////////////////////////////////////////////////////////////////////////////////////////////

pred show{
	(all c:City| #(c.streets) = 2 ) and
	all vt: ViolationType | #vt.interventions > 0 
	--#ReportsRequest = 1
	
	--all s: Street | #s.reports = 0
}
run show for 5 but 2 StreetName, 2 Registration, 
									1 User, 1 City, 2 Intervention,
									3 Position, 2 ViolationType,2 Report, 2 Accident,
									2 AccidentType, 2 StoredReport
