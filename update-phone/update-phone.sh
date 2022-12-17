#/bin/bash

NewPhoneNumber='<New Phone number>'
RoleName='<Role Name to assume into target account>'

touch account-contact-info.logs updated-account.logs
cat /dev/null > account-update.logs 
cat /dev/null > update-done.logs  

export ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
export SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
export SESSION_TOKEN=$AWS_SESSION_TOKEN

for PROD_ACCOUNT in `cat account-list.txt`;
do

echo "Working on $PROD_ACCOUNT"

export AWS_ACCESS_KEY_ID=$ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$SECRET_ACCESS_KEY
export AWS_SESSION_TOKEN=$SESSION_TOKEN


role=$(aws sts assume-role --role-arn "arn:aws:iam::${PROD_ACCOUNT}:role/${RoleName}" --role-session-name "update-contact-information");
export AWS_ACCESS_KEY_ID=$(echo $role | jq -r .Credentials.AccessKeyId);
export AWS_SECRET_ACCESS_KEY=$(echo $role | jq -r .Credentials.SecretAccessKey);
export AWS_SESSION_TOKEN=$(echo $role | jq -r .Credentials.SessionToken);

info=$(aws account get-contact-information)

address_line01=$(echo $info| jq -r '.ContactInformation.AddressLine1 // empty')
address_line02=$(echo $info| jq -r '.ContactInformation.AddressLine2 // empty') 
address_line03=$(echo $info| jq -r '.ContactInformation.AddressLine3 // empty')
city=$(echo $info| jq -r '.ContactInformation.City // empty')
companyname=$(echo $info| jq -r '.ContactInformation.CompanyName // empty')
countrycode=$(echo $info| jq -r '.ContactInformation.CountryCode // empty')
fullname=$(echo $info| jq -r '.ContactInformation.FullName // empty')
phonenumber=$(echo $info| jq -r '.ContactInformation.PhoneNumber // empty')
postalcode=$(echo $info| jq -r '.ContactInformation.PostalCode // empty')
stateorregion=$(echo $info| jq -r '.ContactInformation.StateOrRegion // empty')

if [ "$phonenumber" != "$NewPhoneNumber" ]; then
# log the old contact information 
    echo "=====$PROD_ACCOUNT=====\naddress_line01: $address_line01\naddress_line02: $address_line02\naddress_line03: $address_line03\ncity: $city\ncompanyname: $companyname\ncountrycode: $countrycode\nfullname: $fullname\nphonenumber: $phonenumber\npostalcode: $postalcode\nstateorregion: $stateorregion\n" >> account-contact-info.logs

    contactInfo=\'{
    [ -z "$address_line01" ] || contactInfo="$contactInfo\"AddressLine1\":\"$address_line01\""
    [ -z "$address_line02" ] || contactInfo="$contactInfo,\"AddressLine2\":\"$address_line02\""
    [ -z "$address_line03" ] || contactInfo="$contactInfo,\"AddressLine3\":\"$address_line03\""

    [ -z "$city" ] || contactInfo="$contactInfo,\"City\":\"$city\""
    [ -z "$companyname" ] || contactInfo="$contactInfo,\"CompanyName\":\"$companyname\""
    [ -z "$countrycode" ] || contactInfo="$contactInfo,\"CountryCode\":\"$countrycode\""
    [ -z "$fullname" ] || contactInfo="$contactInfo,\"FullName\":\"$fullname\""
    # Update new phone number
    contactInfo="$contactInfo,\"PhoneNumber\":\"$NewPhoneNumber\""
    [ -z "$postalcode" ] || contactInfo="$contactInfo,\"PostalCode\":\"$postalcode\""
    [ -z "$stateorregion" ] || contactInfo="$contactInfo,\"StateOrRegion\":\"$stateorregion\""
    contactInfo="$contactInfo}'"


    contactInfo="aws account put-contact-information --contact-information $contactInfo"

    #execute the command to update contact information 
    eval "$contactInfo" && echo "Phone number has been updated for $PROD_ACCOUNT" >> updated-account.logs 

## If phone number is already updated
else
    echo "Phone number is already updated for $PROD_ACCOUNT"
fi

done

