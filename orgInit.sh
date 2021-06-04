#temp directory for working files
mkdir sfdx_temp

#create scratch org
sfdx force:org:create -s -f config/project-scratch-def.json -d 14 -s -w 60

#apply security settins
sfdx force:source:deploy -m Settings:Security

#push custom fields
sfdx force:source:push -f

sfdx force:user:permset:assign --permsetname AllowAuditFieldsInactiveOwner

#prep unique Username in User csv
sed "s/{TIMESTAMP}/$(date "+%Y%m%d%H%M%S")/g" data/core/User.csv > sfdx_temp/User_Load.csv

#load csvs into core objects
sfdx force:data:bulk:upsert -s UserRole -f data/core/UserRole.csv -i Name -w 2
sfdx force:data:bulk:upsert -s User -f sfdx_temp/User_Load.csv -i External_Id__c -w 2
sfdx force:data:bulk:upsert -s Account -f data/core/Account.csv -i External_Id__c -w 5
sfdx force:data:bulk:upsert -s Opportunity -f data/core/Opportunity.csv -i External_Id__c -w 5

#create records for key objects
sfdx force:data:record:create -s Task -v "Subject='Call'"
sfdx force:data:record:create -s Event -v "Subject='Call' DurationInMinutes='1' ActivityDateTime='2019-01-01'"
sfdx force:data:record:create -s Task -v "Subject='Sample Task'"
sfdx force:data:record:create -s Event -v "Subject='Sample Call' DurationInMinutes='1' ActivityDateTime='2019-01-01'"
sfdx force:data:record:create -s Case -v "Subject='Sample Case'"
sfdx force:data:record:create -s Campaign -v "Name='Sample Campaign'"
sfdx force:data:record:create -s Lead -v "LastName='Sample Lead' Company='Sample Company'"
sfdx force:data:record:create -s Contact -v "LastName='Sample Contact'"

# #upload any Analytics datasets
# sfdx shane:analytics:dataset:upload -f data/analytics/Customer_Comments.csv -m data/analytics/Customer_Comments.json -n "Customer Comments"

#clean up
rm -rf sfdx_temp

sfdx force:user:password:generate

sfdx force:user:display

#open org
sfdx force:org:open -p /lightning/page/home
