open util/boolean

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
	isSafe: one Bool,
	positions: some Position
	--safetyType: one SafetyType
}

sig StreetName{
}

sig Position{}

sig ViolationType{
	suggestedInterventions: set SuggestedIntervention
}

sig VehicleType{}

sig SuggestedIntervention{}

sig Report{
	user: one User,
	position: one Position,
	violationType: one ViolationType,
	vehicleType: one VehicleType
	
}


--abstract sig SafetyType{}
--one sig Safe extends SafetyType{}
--one sig Unsafe extends SafetyType{}


--STREETS

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



--REGISTRATION

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

pred show{}
run show for 5 but 2 StreetName, 2 Registration, 0 User
 
