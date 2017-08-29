#!/bin/bash
#tar cfz Dashboard_Widgets_${Environment}_${BUILD_NUMBER}.tar.gz ./bin

echo "Publishing this artifact to Artifactory"
curl -X PUT -u 502712493:AP3QVE55ZDfXm8giwQn6JSFfem6 https://devcloud.swcoe.ge.com/artifactory/XPIQO-SNAPSHOT/Widgets/testwidgets/ --upload-file *.tar.gz

echo ARTIFACT is Dashboard_Widgets_${BUILD_NUMBER}.tar.gz
