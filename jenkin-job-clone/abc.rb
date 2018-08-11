#!/usr/bin/env ruby

require 'benchmark'
require 'jenkins_api_client'
require 'json'

@client = JenkinsApi::Client.new(
  :server_url => 'https://isjenkins.dsa.apps.ge.com/',
  :username   => '212609073',
  :password   => '340fb0036a0f72f6623748efbe5f6930',
  #:log_level  => Logger::DEBUG,
)

def api
  def find_jobs(jobs, folder_path = nil)
    # path should not have a leading `/`
    found = []

    jobs.each do |job|
      name = job['name']
      if folder_path
        # add folder path to job name
        name = "#{folder_path}/#{job['name']}"
        job['name'] = name
      end

      found << job

      if job['_class'] == 'com.cloudbees.hudson.plugins.folder.Folder'
        # mangle "folder" path into "API" path
        api_path = '/job/' + name.split('/').join('/job/')
        folder = @client.api_get_request(api_path, "tree=jobs[name]")["jobs"]
        found += find_jobs(folder, name)
      end
    end

    found
  end

  jobs = @client.api_get_request("", "tree=jobs[name]")["jobs"]
  find_jobs(jobs)
end

def groovy
  # based on groovy code I hacked together for recursively listing jobs/folders
  # for the puppet jenkins module
  # https://github.com/jenkinsci/puppet-jenkins/blob/master/files/puppet_helper.groovy
  text = @client.exec_script(<<'EOS')
    def Map findJobs(Object obj, String namespace = null) {
      def found = [:]

      // groovy apparently can't #collect on a list and return a map?
      obj.items.each { job ->
        // a possibly better approach would be to walk the parent chain from //
        // each job
        def path = job.getName()
        if (namespace) {
          path = "${namespace}/" + path
        }
        found[path] = job
        // intentionally not using `instanceof` here so we don't blow up if the
        // cloudbees-folder plugin is not installed
        if (job.getClass().getName() == 'com.cloudbees.hudson.plugins.folder.Folder') {
          found << findJobs(job, path)
        }
      }

      found
    }

    void job_list_json() {
      def jobs = findJobs(Jenkins.getInstance())

      def allInfo = jobs.collect { path, job ->
        // at least these job classes do not respond to respond to #isDisabled:
        // - org.jenkinsci.plugins.workflow.job.WorkflowJob
        // - com.cloudbees.hudson.plugins.folder.Folder
        def enabled = false
        if (job.metaClass.respondsTo(job, 'isDisabled')) {
          enabled = !job.isDisabled()
        }

        [
          _class: job.getClass().toString(),
          name: path,
        ]
      }

      def builder = new groovy.json.JsonBuilder(allInfo)
      out.println(builder.toPrettyString())
    }

    job_list_json()
EOS

  JSON.parse(text)
end

n = 10
Benchmark.bmbm do |x|
  x.report('api:')   { n.times { api } }
  x.report('groovy:')  { n.times { groovy } }
end
