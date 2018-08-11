#!groovy


    FILES_DIR = '/var/lib/jenkins/' 
 	//Home directory	/var/lib/jenkins
    cleanWs()

    def TMP_FILENAME = ".folder_list"
    sh "ls ${FILES_DIR} > ${TMP_FILENAME}"
    def filenames = readFile(TMP_FILENAME).split( "\\r?\\n" );
    //sh "rm -f ${TMP_FILENAME}"

    for (int i = 0; i < filenames.size(); i++) {
        def filename = filenames[i]
        echo "${filename}"
    }

