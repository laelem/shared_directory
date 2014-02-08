#####################################################################################################
# MODELS
#####################################################################################################

MAX_SIZE_DEFAULT_INPUT_TEXT = 255
DEFAULT_NAME_REGEX = /\A[a-zA-Z\s\-']+\z/
PATH_FAKE_FILES = Rails.root.join('doc', 'fake_files')

# USER
MIN_SIZE_USER_PASSWORD = 6
MAX_SIZE_USER_PASSWORD = 15
MAX_SIZE_USER_FIRST_NAME = 50
MAX_SIZE_USER_LAST_NAME = 50
VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

# JOB
MIN_SIZE_JOB_NAME = 5

# COUNTRY
SIZE_COUNTRY_CODE = 2
MIN_SIZE_COUNTRY_NAME = 3

# CONTACT
CIV = { "Mr" => "Mister", "Mrs" => "Missus", "Ms" => "Miss"}
MIN_SIZE_CONTACT_FIRST_NAME = 2
MAX_SIZE_CONTACT_FIRST_NAME = 50
MIN_SIZE_CONTACT_LAST_NAME = 2
MAX_SIZE_CONTACT_LAST_NAME = 50
MAX_SIZE_CONTACT_COMMENT = 500
SIZE_ZIP_CODE = 5
MIN_SIZE_TEL = 6
MAX_SIZE_TEL = 15
# UPLOAD
MAX_SIZE_CONTACT_PHOTO = 2.megabytes
UPLOAD_PATH_CONTACT_PHOTO = File.join('upload', 'contact', 'photo').to_s
ROWS_IMG_CONTACT_PHOTO = 100
COLS_IMG_CONTACT_PHOTO = 100


#####################################################################################################
# MODULES
#####################################################################################################

CLASS_ERROR = '.error'
CLASS_SUCCESS = '.success'
SIZE_DEFAULT_INPUT_TEXT = 50
SIZE_DEFAULT_TEXT_AREA = "50x3"

# JOBS
JOBS_SORTING_COLS = ["name", "active"]
JOBS_DEFAULT_SORT = { field: "name", type: "asc" }
unless Rails.env.test?
  JOBS_PER_PAGE = [10, 20, 50, "all"]
  JOBS_DEFAULT_PER_PAGE = 10
else
  JOBS_PER_PAGE = [2, 4, 6, "all"]
  JOBS_DEFAULT_PER_PAGE = 2
end

# USERS
USERS_SORTING_COLS = ["first_name", "last_name", "active", "email"]
USERS_DEFAULT_SORT = { field: "last_name", type: "asc" }
unless Rails.env.test?
  USERS_PER_PAGE = [10, 20, 50, "all"]
  USERS_DEFAULT_PER_PAGE = 10
else
  USERS_PER_PAGE = [2, 4, 6, "all"]
  USERS_DEFAULT_PER_PAGE = 2
end

# CONTACTS
CONTACTS_SORTING_COLS = ["first_name", "last_name", "active", "job", "email"]
CONTACTS_DEFAULT_SORT = { field: "last_name", type: "asc" }
unless Rails.env.test?
  CONTACTS_PER_PAGE = [10, 20, 50, 100, "all"]
  CONTACTS_DEFAULT_PER_PAGE = 20
else
  CONTACTS_PER_PAGE = [2, 4, 6, "all"]
  CONTACTS_DEFAULT_PER_PAGE = 2
end