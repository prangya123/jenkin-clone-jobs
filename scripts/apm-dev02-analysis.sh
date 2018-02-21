##Create new space
cf create-space apm-dev02-analysis -o OGD_Development_USWest_01
cf t -o OGD_Development_USWest_01 -s pm-dev02-analysis
##Create services
cf cups apm-asset -p  '{"uri": "https://apm-asset-svc-preprod.preprod-app-api.aws-usw02-pr.predix.io/v1","health_endpoint": "https://apm-asset-svc-preprod.preprod-app-api.aws-usw02-pr.predix.io/system_status"}'
cf cups stuf -p '{"adminUrl": "https://stuf-stufprod.apm.aws-usw02-pr.predix.io/admin-3frla3cg2","clientId": "16n7kl5z53jdxpx3s5lwucdfjvgjkhro07lyqy","clientSecret": "q5lu1jw2l7jkc0mol50pezpbo2dzccbyywavp","configServiceUrl": "https://config-stuf-stufprod.apm.aws-usw02-pr.predix.io","securityServiceUrl": "https://security-stuf-stufprod.apm.aws-usw02-pr.predix.io","serviceInstanceId": "26b305ec-f801-4e76-b03a-ef409403546e","tenantServiceUrl": "https://tenancy-stuf-stufprod.apm.aws-usw02-pr.predix.io","tokenServiceUrl": "https://token-service-stuf-stufprod.apm.aws-usw02-pr.predix.io","trustedIssuer": "https://f6d0524d-28d1-4af8-a21c-3c779790aff4.predix-uaa.run.aws-usw02-pr.ice.predix.io/oauth/token","uaaUrl": "https://f6d0524d-28d1-4af8-a21c-3c779790aff4.predix-uaa.run.aws-usw02-pr.ice.predix.io","userServiceUrl": "https://users-stuf-stufprod.apm.aws-usw02-pr.predix.io"}'
cf cups apm-view-proxy -p '{"uri": "https://apm-view-proxy-svc-preprod.preprod-app-api.aws-usw02-pr.predix.io/v1"}'
cf cups apm-timeseries-services -p '{"health_endpoint": "https://apm-timeseries-query-svc-preprod.preprod-app-api.aws-usw02-pr.predix.io/system_status","uri": "https://apm-timeseries-query-svc-preprod.preprod-app-api.aws-usw02-pr.predix.io"}'
cf cups apm-template -p '{"uri": "https://apm-templates-svc-preprod.preprod-app-api.aws-usw02-pr.predix.io/v1"}'
cf cups apm-alarm-management -p '{"uri": "https://apm-alarms-svc-preprod.preprod-app-api.aws-usw02-pr.predix.io/v1"}'
cf cups upstream-pumpcurve -p '{"uri": "https://ogd-is-transformer-dev02.run.aws-usw02-pr.ice.predix.io/v1"}'
cf cups upstream-iprcurve-integration -p '{"uri": "https://ogd-is-iprcurve-dev02.run.aws-usw02-pr.ice.predix.io/v1"}'
cf cups upstream-gradientcurve-integration -p '{"uri": "https://ogd-is-gradientcurve-dev02.run.aws-usw02-pr.ice.predix.io/v1"}'
cf cups upstream-wellmodel -p  '{"uri": "https://ogd-is-wellmodel-dev02.run.aws-usw02-pr.ice.predix.io"}'
cf cups apm-analytic -p '{"uri": "https://caf-mgmt-svc-preprod.preprod-app-api.aws-usw02-pr.predix.io"}'
cf cups apm-widget-repo-service -p '{"uri": "https://apm-widget-repo-service-svc-apm-dev02.apm.aws-usw02-pr.predix.io"}'
cf create-service redis-16 shared-vm avid-redis
