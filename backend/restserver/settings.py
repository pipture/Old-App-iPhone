# Django settings for restserver project.

import os.path

APP_DIR = os.path.dirname(__file__)

DEBUG = False
TEMPLATE_DEBUG = DEBUG

ADMINS = (
)

MANAGERS = ADMINS

#there is a settings for local DB (sqlite)
#lower: from settings_staging import *
#There is overwriting DATABASES section

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3', # Add 'postgresql_psycopg2', 'postgresql', 'mysql', 'sqlite3' or 'oracle'.
        'NAME': os.path.join( APP_DIR, 'sqlite.db' ),
        'USER': '',                      # Not used with sqlite3.
        'PASSWORD': '',                  # Not used with sqlite3.
        'HOST': '',                      # Set to empty string for localhost. Not used with sqlite3.
        'PORT': '',                      # Set to empty string for default. Not used with sqlite3.
    }
}

# Local time zone for this installation. Choices can be found here:
# http://en.wikipedia.org/wiki/List_of_tz_zones_by_name
# although not all choices may be available on all operating systems.
# On Unix systems, a value of None will cause Django to use the same
# timezone as the operating system.
# If running in a Windows environment this must be set to the same as your
# system time zone.
TIME_ZONE = 'UTC'

# Language code for this installation. All choices can be found here:
# http://www.i18nguy.com/unicode/language-identifiers.html
LANGUAGE_CODE = 'en-us'

SITE_ID = 1

# If you set this to False, Django will make some optimizations so as not
# to load the internationalization machinery.
USE_I18N = True

# If you set this to False, Django will not format dates, numbers and
# calendars according to the current locale
USE_L10N = True

# URL that handles the media served from MEDIA_ROOT. Make sure to use a
# trailing slash if there is a path component (optional in other cases).
# Examples: "http://media.lawrence.com", "http://example.com/media/"
STATIC_ROOT = os.path.join(APP_DIR, 'static')
STATIC_URL = '/static/'

# Make this unique, and don't share it with anybody.
SECRET_KEY = '&#a%(19x83i%5gre1$v10)exjq6taz!=e%o8vjv6&x-b3um0d)'

# See http://docs.djangoproject.com/en/dev/topics/logging for
# more details on how to customize your logging configuration.
LOGGING = {
    'version': 1,
    'disable_existing_loggers': True,
    'root': {
        'level': 'WARNING',
        'handlers': ['console'],
    },
    # Loggers
    # A logger is the entry point into the logging system. Each logger is a named bucket to which messages
    # can be written for processing.
    #  DEBUG:     Low level system information for debugging purposes
    #  INFO:      General system information
    #  WARNING:   Information describing a minor problem that has occurred.
    #  ERROR:     Information describing a major problem that has occurred.
    #  CRITICAL:  Information describing a critical problem that has occurred.
    'loggers': {
        'django': {
            'handlers':['null'],
            'level':'INFO',
            'propagate': True,
        },
        'django.request': {
            'handlers': ['console'],
            'level': 'ERROR',
            'propagate': False,
        },

        'django.db.backends': {
            'handlers': ['console'],
            'level': 'ERROR',
            'propagate': False,
        },

        'restserver.rest_core': {
            'handlers': ['console', 'dev_console'],
            'level': 'INFO',
        },
        'restserver.api': {
            'handlers': ['console', 'dev_console'],
            'level': 'INFO',
        },

        'apiclient.discovery': {
            'handlers': ['dev_console'],
            'level': 'INFO',
        },
    },

    'handlers': {
        'null': {
            'level': 'INFO',
            'class': 'django.utils.log.NullHandler',
        },
        'console': {
            'level': 'WARNING',
            'class': 'logging.StreamHandler',
            'formatter': 'simple'
        },
        'mail_admins': {
            'level': 'DEBUG',
            'class': 'django.utils.log.AdminEmailHandler',
            'include_html': True,
        },
        'dev_console': {
            'level': 'DEBUG',
            'class': 'logging.StreamHandler',
            'formatter': 'simple'
        },
    },
    # Formatters
    # Ultimately, a log record needs to be rendered as text. Formatters describe the exact format of that text.
    # A formatter usually consists of a Python formatting string; however, you can also write custom formatters
    # to implement specific formatting behavior.
    'formatters': {
        'verbose': {
            'format': '%(levelname)s %(asctime)s %(module)s %(process)d %(thread)d %(message)s'
        },
        'simple': {
            'format': '%(levelname)s %(message)s'
        },
    },
}

CACHES = {
    'default': {
        'BACKEND': 'restserver.api.cache.ApiCache',
        'TIMEOUT': 60 * 5,
        'LOCATION': '/tmp/pipture/cache/',
    },
    'google_analytics': {
        'BACKEND': 'restserver.api.cache.ApiCache',
        'TIMEOUT': 60 * 5,
        'LOCATION': '/tmp/pipture/cache/',
    },
}

# List of callables that know how to import templates from various sources.
TEMPLATE_LOADERS = (
    'django.template.loaders.filesystem.Loader',
    'django.template.loaders.app_directories.Loader',
#     'django.template.loaders.eggs.Loader',
)

MIDDLEWARE_CLASSES = (
    'django.middleware.common.CommonMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'restserver.api.middleware.threadlocals.LocalUserMiddleware',
)

ROOT_URLCONF = 'restserver.urls'

TEMPLATE_DIRS = (
    os.path.join(APP_DIR, 'templates'),
)

STATICFILES_FINDERS = (
    'django.contrib.staticfiles.finders.AppDirectoriesFinder',
    'django.contrib.staticfiles.finders.FileSystemFinder',
#    'django.contrib.staticfiles.finders.DefaultStorageFinder',
)

INSTALLED_APPS = (
    'db_connection_pool',

    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.sites',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'django.contrib.admin',

    'restserver.s3',
    'restserver.api',
    'restserver.rest_core',
    'restserver.pipture',
    'restserver.video_player',

    'django.contrib.admindocs',

    'south',
)

AUTH_PROFILE_MODULE = 'pipture.UserProfile'

ACTIVE_DAYS_TIMESLOTS = 1

try:
    from settings_staging import *
except ImportError:
    pass

MESSAGE_VIEWS_LOWER_LIMIT = 10
