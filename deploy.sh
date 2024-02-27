while getopts n:l:c:u:p:v: flag
do
    case "${flag}" in
        n) NAME=${OPTARG};;
        l) LOCATION=${OPTARG};;
        c) CODE=${OPTARG};;
        u) USERNAME=${OPTARG};;
        p) PASSWORD=${OPTARG};;
        v) VERSION=${OPTARG};;
    esac
done

if [ "$NAME" == "" ] || [ "$LOCATION" == "" ] || [ "$CODE" == "" ] || [ "$USERNAME" == "" ] || [ "$PASSWORD" == "" ]; then
 echo "Syntax: $0 -n <name> -l <location> -c <unique code> -u <admin username> -p <admin password>"
 exit 1;
elif [[ $CODE =~ [^a-zA-Z0-9] ]]; then
 echo "Unique code must contain ONLY letters and numbers. No special characters."
 echo "Syntax: $0 -n <name> -l <location> -c <unique code> -u <admin username> -p <admin password>"
 exit 1;
fi

SECONDS=0
echo "Start time: $(date)"

# upload server configuration package to storage account
az storage blob upload \
    --account-name stg$NAME$CODE \
    --container-name dsc \
    --name ServerConfiguration-v$VERSION.zip \
    --file ./artifacts/ServerConfiguration.zip \
    --overwrite

# provision infrastructure
az deployment sub create \
    --name $NAME \
    --location $LOCATION \
    --template-file ./iac/main.bicep \
    --parameters name=$NAME \
                location=$LOCATION \
                uniqueSuffix=$CODE \
                adminUsername=$USERNAME \
                adminPassword=$PASSWORD \
                version=$VERSION

duration=$SECONDS
echo "End time: $(date)"
echo "$(($duration / 3600)) hours, $(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."