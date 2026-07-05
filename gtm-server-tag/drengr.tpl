___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Drengr",
  "brand": {
    "id": "drengr",
    "displayName": "Drengr"
  },
  "description": "Forwards every GA4-model event this server container receives to Drengr, so it lands as a named event in your Drengr analysis layer. No client-side changes required.",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "writeKey",
    "displayName": "Drengr Write Key",
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ],
    "help": "Your Drengr publishable write key (starts with drengr_pk_). Find it in the Drengr console under Settings → API Keys."
  },
  {
    "type": "TEXT",
    "name": "endpointUrl",
    "displayName": "Endpoint override (advanced)",
    "simpleValueType": true,
    "defaultValue": "https://ziryfxrwrvnunwjupgfg.supabase.co/functions/v1/segment-ingest",
    "help": "Leave as-is unless Drengr support told you to point at a different ingest URL."
  }
]


___SANDBOXED_JS_FOR_SERVER___

/**
 * Drengr — GA4 event forwarder (server-side GTM tag).
 * Reads the GA4-model event this container just processed, reshapes it into
 * a Segment-spec track call, and POSTs it to Drengr's segment-ingest
 * endpoint. Drengr's endpoint does its own event-name normalization, so the
 * raw event_name is forwarded verbatim.
 *
 * PII: GA4's user_data (email/phone/address, hashed or raw) is dropped
 * entirely before anything leaves this container — never forwarded.
 */

const getAllEventData = require('getAllEventData');
const sendHttpRequest = require('sendHttpRequest');
const JSON = require('JSON');
const logToConsole = require('logToConsole');

const eventData = getAllEventData();

const anonymousId = eventData.client_id || '';
const userId = eventData.user_id || '';
const eventName = eventData.event_name || '';
const ts = eventData.timestamp; // rarely set on GA4 hits; forwarded only if present

// context.app/os/device — best-effort. GA4's documented "common event data"
// has no app/os/device fields for web hits; these only show up on
// Firebase/GA4(App)-origin events. Forwarded when present, never fabricated.
const context = {};
if (eventData.app_id || eventData.app_version) {
  context.app = {};
  if (eventData.app_id) context.app.name = eventData.app_id;
  if (eventData.app_version) context.app.version = eventData.app_version;
}
if (eventData.os_name || eventData.platform || eventData.os_version) {
  context.os = {
    name: eventData.os_name || eventData.platform || ''
  };
  if (eventData.os_version) context.os.version = eventData.os_version;
}
if (eventData.device_model || eventData.device_brand) {
  context.device = { model: eventData.device_model || eventData.device_brand };
}
const hasContext = !!(context.app || context.os || context.device);

// properties — every remaining event-data key, minus internals:
//  - x-ga-*   : GA4 client-internal plumbing, never meant to leave the container
//  - user_data: GA4's PII slot (hashed/raw email, phone, address) — never forwarded
//  - the fields already placed above (event_name/client_id/user_id/timestamp)
const properties = {};
for (var key in eventData) {
  if (key === 'event_name' || key === 'client_id' || key === 'user_id' || key === 'timestamp') continue;
  if (key === 'user_data') continue;
  if (key.indexOf('x-ga-') === 0) continue;
  properties[key] = eventData[key];
}

const body = {
  writeKey: data.writeKey,
  type: 'track',
  event: eventName,
  anonymousId: anonymousId,
  properties: properties
};
if (userId) body.userId = userId;
if (ts) body.timestamp = ts;
if (hasContext) body.context = context;

const endpoint = data.endpointUrl || 'https://ziryfxrwrvnunwjupgfg.supabase.co/functions/v1/segment-ingest';

sendHttpRequest(endpoint, {
  headers: { 'Content-Type': 'application/json' },
  method: 'POST',
  timeout: 5000
}, JSON.stringify(body)).then((result) => {
  if (result.statusCode >= 200 && result.statusCode < 300) {
    data.gtmOnSuccess();
  } else {
    logToConsole('Drengr tag: non-2xx from segment-ingest', result.statusCode, result.body);
    data.gtmOnFailure();
  }
}, (error) => {
  logToConsole('Drengr tag: request failed', error);
  data.gtmOnFailure();
});


___SERVER_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "read_event_data",
        "versionId": "1"
      },
      "param": [
        {
          "key": "eventDataAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "send_http",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedUrls",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "urls",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "https://ziryfxrwrvnunwjupgfg.supabase.co/functions/v1/segment-ingest*"
              },
              {
                "type": 1,
                "string": "https://*.supabase.co/*"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: 'Forwards a track event, drops PII and internal GA4 keys'
  code: |-
    // NOTE: we only assert on the synchronous call into sendHttpRequest, not
    // on gtmOnSuccess/gtmOnFailure — asserting those requires observing a
    // callback queued off the returned promise, and there isn't a
    // documented/verified way to deterministically flush that inside a test
    // (vs. fabricating an unverified test API). The request shape asserted
    // here is exactly the security-critical contract: PII and internal keys
    // must never leave the container.
    const JSON = require('JSON');
    const mockData = {
      writeKey: 'drengr_pk_test123',
      endpointUrl: 'https://ziryfxrwrvnunwjupgfg.supabase.co/functions/v1/segment-ingest'
    };

    mock('getAllEventData', function() {
      return {
        event_name: 'purchase',
        client_id: 'GA1.1.111.222',
        user_id: 'user-42',
        page_location: 'https://shop.example.com/cart',
        value: 19.99,
        'x-ga-mp2-seg': 'internal-only',
        user_data: { sha256_email_address: 'should-never-be-forwarded' }
      };
    });

    let capturedUrl, capturedOptions, capturedBody;
    mock('sendHttpRequest', function(url, options, requestBody) {
      capturedUrl = url;
      capturedOptions = options;
      capturedBody = requestBody;
      return Promise.create((resolve) => {
        resolve({ statusCode: 200, headers: {}, body: '{"success":true}' });
      });
    });

    runCode(mockData);

    assertApi('sendHttpRequest').wasCalled();
    assertThat(capturedUrl).isEqualTo('https://ziryfxrwrvnunwjupgfg.supabase.co/functions/v1/segment-ingest');
    assertThat(capturedOptions.method).isEqualTo('POST');

    const parsed = JSON.parse(capturedBody);
    assertThat(parsed.type).isEqualTo('track');
    assertThat(parsed.event).isEqualTo('purchase');
    assertThat(parsed.anonymousId).isEqualTo('GA1.1.111.222');
    assertThat(parsed.userId).isEqualTo('user-42');
    assertThat(parsed.writeKey).isEqualTo('drengr_pk_test123');
    assertThat(parsed.properties.user_data).isUndefined();
    assertThat(parsed.properties['x-ga-mp2-seg']).isUndefined();
    assertThat(parsed.properties.page_location).isEqualTo('https://shop.example.com/cart');
    assertThat(parsed.context).isUndefined();

- name: 'Includes app/os/device context only when GA4 data has it'
  code: |-
    const JSON = require('JSON');
    const mockData = { writeKey: 'drengr_pk_test123' };

    mock('getAllEventData', function() {
      return {
        event_name: 'screen_view',
        client_id: 'GA1.1.999.888',
        app_id: 'com.example.app',
        app_version: '3.2.1',
        os_name: 'Android',
        os_version: '14'
      };
    });

    let capturedBody;
    mock('sendHttpRequest', function(url, options, requestBody) {
      capturedBody = requestBody;
      return Promise.create((resolve) => { resolve({ statusCode: 200 }); });
    });

    runCode(mockData);

    const parsed = JSON.parse(capturedBody);
    assertThat(parsed.context.app.name).isEqualTo('com.example.app');
    assertThat(parsed.context.app.version).isEqualTo('3.2.1');
    assertThat(parsed.context.os.name).isEqualTo('Android');
    assertThat(parsed.context.os.version).isEqualTo('14');


___NOTES___

Built for Drengr's segment-ingest endpoint (Segment HTTP API-compatible track
calls). Source: integrations/gtm-server-tag/ in the Drengr repo.
