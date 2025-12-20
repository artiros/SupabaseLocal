# Sample Edge Function - Main entry point
# Place your edge functions in this directory

import { serve } from "https://deno.land/std@0.131.0/http/server.ts"

serve(async (req) => {
    return new Response(
        JSON.stringify({ message: "Hello from Supabase Edge Functions!" }),
        { headers: { "Content-Type": "application/json" } }
    )
})
