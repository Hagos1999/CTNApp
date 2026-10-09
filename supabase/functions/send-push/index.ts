import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.38.4'

// In a real scenario, use google-auth-library or just raw fetch with the Firebase Server Key
// To keep it simple, here is how you call the FCM API using an older legacy key, or ideally
// you use a service account with the Firebase Admin SDK if you deploy on Deno.

const FIREBASE_SERVER_KEY = Deno.env.get('FIREBASE_SERVER_KEY')!;

serve(async (req) => {
  try {
    // 1. Parse the incoming Database Webhook payload
    const payload = await req.json()
    const record = payload.record

    // 2. Check the condition (e.g., power > 100W)
    if (record && record.power > 100) {
      
      // 3. Initialize Supabase Admin client
      const supabaseAdmin = createClient(
        Deno.env.get('SUPABASE_URL') ?? '',
        Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
      )

      // 4. Fetch the FCM token for this device's owner
      // Assuming 'sensor_readings' has a 'device_id' which maps to a user
      // Adjust this query based on how your device_id maps to user_id
      const { data: tokenData, error: tokenError } = await supabaseAdmin
        .from('fcm_tokens')
        .select('token')
        // .eq('user_id', ownerId) // You need to link device -> user here
        .limit(1)
        .single()

      if (tokenData && tokenData.token) {
        // 5. Send Push Notification via Firebase
        const fcmResponse = await fetch('https://fcm.googleapis.com/fcm/send', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            Authorization: `key=${FIREBASE_SERVER_KEY}`,
          },
          body: JSON.stringify({
            to: tokenData.token,
            notification: {
              title: '⚡ Power Spike Detected!',
              body: `Current power usage is ${record.power}W (exceeds 100W limit).`,
              sound: 'default'
            },
            data: {
              device_id: record.device_id,
              click_action: 'FLUTTER_NOTIFICATION_CLICK',
            },
          }),
        })

        const fcmResult = await fcmResponse.json()
        console.log('FCM Send Result:', fcmResult)
      }
    }

    return new Response(JSON.stringify({ success: true }), {
      headers: { 'Content-Type': 'application/json' },
    })
  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), {
      status: 400,
      headers: { 'Content-Type': 'application/json' },
    })
  }
})