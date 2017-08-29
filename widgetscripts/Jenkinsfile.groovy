#!/usr/bin/env groovy

node('Linux (amd64)') {
	try {
        	stage('Checkout Widgets') {
           	
			git credentialsId: '503ab059-72ac-40b7-939b-f0af88242bfb', url: 'git@github.build.ge.com:OG-Commons/Devops_utils.git'	
			dir('widgetscripts') {
            		sh 'ls -al'
        	}
       		 }

        	stage('Build Widgets') {
             		
        	}

        	stage('Validate Widgets') {
            		
        	}
    
        	stage('Push to Artifactory') {
            		
        	}
        	stage('deploy to dev') {
            
		}	
	catch(error) {
       		 throw error
   	 } finally {
     	 }

}
