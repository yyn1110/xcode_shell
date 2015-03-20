#!/usr/bin/env python
'Analysis Miao Project '
import os
import time
from biplist import *
class APP(object):
	"""docstring for APP"""
	app_analysis_file = ''
	
	app_target_name = ''
	app_project_path = ''
	app_title = 'Miao Build And Analysis'

	def __init__(self,fname):
		super(APP, self).__init__()

		try:
			self.app_analysis_file=open (fname,'a')
			
			
			self.app_target_name =str( os.getenv('TARGET_NAME'))
			self.app_project_path = str(os.getenv('SRCROOT'))
			product_name = str(os.getenv('PRODUCT_NAME'))
			project_name = str(os.getenv('PROJECT_NAME'))
			valid_archs = str(os.getenv('VALID_ARCHS'))
			mi_push_model = str(os.getenv('MiSDKRunKey'))
			build_model = str(os.getenv('CONFIGURATION'))
			
			
			mi_push_string = 'ERROR'
			if build_model == mi_push_model:
				mi_push_string = 'OK'
			else:
				mi_push_string = 'ERROR'
			code_sign = str(os.getenv('CODE_SIGN_IDENTITY'))
			build_time = time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time()))
			self.app_write_log("\n\n------------------------------------------------------\n")
			self.app_write_log("app title:				"+self.app_title)
			self.app_write_log("app build time:				"+build_time)
			self.app_write_log("product name:				"+product_name)
			self.app_write_log("project name:				"+project_name)
			self.app_write_log("Valid Architectures:			"+valid_archs)
			self.app_write_log("xiao mi push switch :			"+mi_push_string)
			self.app_write_log("app target name:			"+self.app_target_name)
			self.app_write_log("app project path:			"+self.app_project_path)
			self.app_write_log("app code sign:			"+code_sign)
			plist_path = str(os.getenv('PROJECT_DIR'))+'/'+ str(os.getenv('INFOPLIST_FILE'))
			# self.app_write_log("plist  path:				"+plist_path)
			try:
				plist = readPlist(plist_path)
				self.app_write_log("app version:				"+str(plist['CFBundleShortVersionString']))
				self.app_write_log("app build version:			"+str(plist['CFBundleVersion']))
				chan = str(plist['channelId'])
				if chan == "":
					self.app_write_log("channelId :				"+'App Store')	
				else:
					self.app_write_log("channelId :					"+chan)	

				self.app_write_log("bundle id :				"+str(plist['CFBundleIdentifier']))
				fileSharingEnabled = str(plist['UIFileSharingEnabled'])
				if fileSharingEnabled == 'False':
						self.app_write_log("UIFileSharingEnabled :				OK")	
				else:
						self.app_write_log("UIFileSharingEnabled :				ERROR")	
			

			except (InvalidPlistException, NotBinaryPlistException), e:
				self.app_write_log("no plist:			"+e)
			else:
				pass
			

			self.app_write_log("Done")
		except IOError, e:
			errStr = " *** file open error:"+e
			self.app_write_log(errStr)
		else:
			self.app_analysis_file.close()
	def app_write_log(self,logStr):
		self.app_analysis_file.writelines(logStr+'\n')

build_file_model = str(os.getenv('CONFIGURATION'))
build_file = "./Miao_"+build_file_model+".txt"
app = APP(build_file)
