sig Username{}

sig Password{}

sig Registration{
	username: one Username,
	password: one Password
}

abstract sig Customer{
	registration: one Registration
}

sig User extends Customer{}

sig Authority extends Customer{
	city: one City,
	unreadReports : set StoredReport
}

fact UnreadReportsRule{
	all sr:StoredReport, a:Authority | sr in a.unreadReports iff
	(
		sr.status = Unread and sr.report.position.street.city in a.city
	)
}

sig City{
	streets: some Street,
	authority: lone Authority
}

sig Street{
	city : one City,
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

fact StreetCityLinked{
	all s:Street, c:City | s in c.streets iff c in s.city
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
--requests

sig ReportsRequest {
	authority : one Authority,
	violationTypes : some ViolationType,
	dates : some Date,
	time : some Time,
	vehicleTypes: some VehicleType,
	street : lone Street
	
}

sig InterventionsRequest{
	city : one City
}

-------------------------------------------------------------------------------------------------------------
--results

sig ReportsResult{
	request : one ReportsRequest,
	storedReports : set StoredReport
}

fact ReportsResultRule{
	all sr:StoredReport, result:ReportsResult | sr in result.storedReports iff
	(
		sr.report.violationType in result.request.violationTypes and
		sr.report.date in result.request.dates and
		sr.report.time in result.request.time and
		sr.report.vehicleType in result.request.vehicleTypes and
		(result.request.street = none implies sr.report.position.street.city in 
			result.request.authority.city else sr.report.position.street in
				result.request.street
		)
	)
}

sig InterventionsResult{
	request : one InterventionsRequest,
	interventions : set Intervention
}

fact InterventionsResultRule{
	all i:Intervention, result:InterventionsResult | i in result.interventions iff 
	(
		some s:Street | s in result.request.city.streets and 
			i in s.suggestedInterventions
	)
}

fact OneResultForOneRequestReports{
	all req : ReportsRequest | one res :ReportsResult | req in res.request
}

fact OneResultForOneRequestIntervention{
	all req : InterventionsRequest | one res :InterventionsResult | req in res.request
}

--///////////////////////////////////////////////////////////////////////////////////////////////////////////
--REPORTS
--///////////////////////////////////////////////////////////////////////////////////////////////////////////

fact NoDuplicateStoredReports{
	no disj r1,r2 : StoredReport | 
		r1.report = r2.report or
		(
			r1.report.position = r2.report.position and
			r1.report.violationType = r2.report.violationType and
			r1.plate = r2.plate and 
			r1.report.date = r2.report.date
		)
}

fact CorrectStreetNameInReport{
	all sr: StoredReport | sr.streetName in 
		sr.report.position.street.streetName
}

fact UnreadReportIfNoAuthority{
	all sr: StoredReport | sr.report.position.street.city.authority = none implies
		sr.status = Unread
}

--///////////////////////////////////////////////////////////////////////////////////////////////////////////
--PREDICATES AND COMMANDS
--///////////////////////////////////////////////////////////////////////////////////////////////////////////

/*pred show{
	(all c:City| #(c.streets) = 2 ) and
	all vt: ViolationType | #vt.interventions > 0 and
	#ReportsResult = 2
	--#ReportsRequest = 1
	
	--all s: Street | #s.reports = 0
}
run show for 5 but 2 StreetName, 2 Registration, 
									1 User, 1 City, 2 Intervention,
									3 Position, 2 ViolationType,2 Report, 2 Accident,
									2 AccidentType, 2 StoredReport, 1 Time,
 2 ReportsRequest
*/

pred world1{
	#Report = 0 and 
	#ReportsRequest = 0 and
	#InterventionsRequest = 0 and
 	#ViolationType = 0 and
	#AccidentType = 0 and

	#City = 3
	#Authority = 2
	#User = 2
}

--run world1 for 4

pred world2{
	#City = 1 and
	#ReportsRequest = 0 and
	#InterventionsRequest = 0 and
	#StoredReport = 2 and
	#Accident = 2 and
	#AccidentType = 1 and
	#Registration = 2 and
	#Intervention = 2 
}
--run world2 for 2

pred world3{
	#City = 1 and
	--#Street = 1 and
	#InterventionsRequest = 1 and
	#ReportsRequest = 0 and
	#Report = 1 and
	#AccidentType = 0 and
	#Accident = 0
	#Intervention = 1

}

run world3 for 2
