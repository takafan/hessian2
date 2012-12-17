# -*- encoding: utf-8 -*-
require 'active_record'
class Profile < ActiveRecord::Base
  establish_connection(adapter: 'mysql2', encoding: 'utf8', database: 'ting_passport', 
    username: 'root', password: '7654321', host: '192.168.3.220')

  self.table_name = "tb_profile"
  self.primary_key = 'uid'

  attr_accessible :uid, :nickname, :gender, :birth_year, :birth_month, :birth_day, :is_secret_year, 
    :blood_type, :constellation, :home_country, :home_province, :home_city, :home_town, :country, :province, :city, :town,
    :mobile, :telephone, :profession, :finish_school, :personal_homepage, :personal_comment, :personal_signature,
    :logo_pic, :email, :create_time, :last_modify_time, :contact_address, :contact_email, :qq, :msn, :status,
    :sub_email, :suit_id, :thirdparty_user_id, :weibo_name, :large_pic, :middle_pic, :small_pic, :is_completed,
    :is_robot, :is_verified, :is_blacklisted, :is_deleted, :registered_ip, :mobile_middle_pic, :mobile_small_pic, 
    :mobile_large_pic, :mobile_special_pic, :is_v_email, :is_v_mobile, :last_track_id, :real_name, :identification,
    :identification_type, :is_login_ban, :login_ban_start, :login_ban_end, :ptitle, :task_complete_profile, :task_follow,
    :task_download_app, :is_guide_completed, :v_company, :v_tags, :v_category_id, :device_token


end
