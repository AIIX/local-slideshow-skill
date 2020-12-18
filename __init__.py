import sys
import requests
import random
import os
import time
import base64
import importlib.util
from os.path import join, dirname, abspath, expanduser
from adapt.intent import IntentBuilder
from mycroft.skills.core import MycroftSkill, intent_handler, intent_file_handler, resting_screen_handler
from mycroft.skills.skill_loader import load_skill_module
from mycroft.util.log import getLogger
from mycroft.messagebus.message import Message
from json_database import JsonStorage
__author__ = 'aix'

LOGGER = getLogger(__name__)

class LocalSlideShowSkill(MycroftSkill):

    # The constructor of the skill, which calls MycroftSkill's constructor
    def __init__(self):
        super(LocalSlideShowSkill, self).__init__(name="LocalSlideShowSkill")
        self.defaultImagePath = expanduser("~/Pictures")
        self.slideshow_list_model = []

    def initialize(self):
        self.gui.register_handler("slideshow.idle.enableTime", self.handle_idle_enable_time)
        self.gui.register_handler("slideshow.idle.disableTime", self.handle_idle_disable_time)
        self.gui.register_handler("slideshow.idle.updateTime", self.handle_idle_update_time)
        self.gui.register_handler("slideshow.idle.removeConfigPage", self.handle_remove_configure_idle_screen)
        self.gui.register_handler("slideshow.idle.setDefaultPath", self.handle_set_default_path)
        self.currentDir = dirname(dirname(abspath(__file__)))
        self.wantedDir = "local-slideshow-data"
        self.dataPath = join(self.currentDir, self.wantedDir)
        self.build_gallery_model()
        
        # Set All Paths
        try:
            os.mkdir(self.dataPath)
        except OSError as error:
            print("Directory Already Exist Skipping")
        self.configDB = join(self.dataPath, 'slideshow-config.db')
        self.idle_config_db = JsonStorage(self.configDB)
        
        # Make Import For TimeData
        try:
            time_date_path = "/opt/mycroft/skills/mycroft-date-time.mycroftai/__init__.py"
            time_date_id = "datetimeskill"
            datetimeskill = load_skill_module(time_date_path, time_date_id)
            from datetimeskill import TimeSkill
            self.dt_skill = TimeSkill()
        except:
            print("Failed To Import DateTime Skill")
            
    def handle_set_default_path(self, message):
        new_path = message.data.get("path")
        self.defaultImagePath = new_path
        self.build_gallery_model()
        self.gui["slideshow_model"] = self.slideshow_list_model
            
    def build_gallery_model(self):
        path = self.defaultImagePath
        files = os.listdir(path)
        images=[]
        for file in files:
            if file.endswith(('.jpg', '.png', '.jpeg')): 
                img_path = os.path.join(path, file)
                images.append({"image": img_path})
        self.slideshow_list_model = images

    def handle_idlescreen_first_run(self):      
        if 'showTime' in self.idle_config_db.keys():
            if self.idle_config_db["showTime"] == False:
                self.gui["showTime"] = False
                self.gui['time_string'] = ""
            else:
                self.gui["showTime"] = True
                self.gui['time_string'] = self.dt_skill.get_display_current_time()
        else:
            self.gui["showTime"] = True
            self.gui['time_string'] = self.dt_skill.get_display_current_time()

    @resting_screen_handler('LocalSlideshow')
    def handle_idle(self, message):
        self.gui.clear()
        self.log.debug('Activating Time/Date resting page')
        self.handle_idlescreen_first_run()
        self.gui["slideshow_model"] = self.slideshow_list_model
        self.gui.show_page('SlideshowIdleScreen.qml')

    def handle_idle_enable_time(self):
        self.speak("I am enabling time")
        self.idle_config_db["showTime"] = True
        self.gui["showTime"] = True
        self.idle_config_db.store()
        # Send Time Data Here First
        self.handle_idle_update_time()

    def handle_idle_disable_time(self):
        self.speak("I am disabling time")
        self.idle_config_db["showTime"] = False
        self.gui["showTime"] = False
        self.idle_config_db.store()
        
    def handle_idle_update_time(self):
        self.gui['time_string'] = self.dt_skill.get_display_current_time()
        
    @intent_handler(IntentBuilder("SlideshowIdleConfigure").require("SlideshowIdleConfigure").build())
    def handle_configure_idle_screen(self):
        self.gui["defaultPath"] = self.defaultImagePath
        self.gui.show_page("ConfigureSlideshowIdle.qml")
    
    def handle_remove_configure_idle_screen(self):
        self.gui.remove_page("ConfigureSlideshowIdle.qml")
        
    def stop(self):
        pass

# The "create_skill()" method is used to create an instance of the skill.
# Note that it's outside the class itself.
def create_skill():
    return LocalSlideShowSkill()
