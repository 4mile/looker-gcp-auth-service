/*

MIT License

Copyright (c) 2022 4 Mile Analytics

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

*/

import dotenv from 'dotenv'
import { ProcessEnv } from '../types'

const envVarNames = {
    LOOKERSDK_BASE_URL: 'LOOKERSDK_BASE_URL',
    SERVER_PORT: 'SERVER_PORT',
    LOOKERSDK_VERIFY_SSL: 'LOOKERSDK_VERIFY_SSL',
    SERVICE_ACCOUNT_EMAIL: 'SERVICE_ACCOUNT_EMAIL',
}

const env = process.env as ProcessEnv

/**
 * Access token server settings. Convenience wrapper around process
 * environment variables. Ensures that the environment variables
 * have been defined.
 */
class Settings {
    constructor() {
        if (!process.env.LOOKERSDK_BASE_URL) {
            const message = `Missing required environment variable: ${envVarNames.LOOKERSDK_BASE_URL}`
            console.error(message)
            throw new Error(message)
        }
        if (!process.env.SERVICE_ACCOUNT_EMAIL) {
            const message = `Missing required environment variable: ${envVarNames.SERVICE_ACCOUNT_EMAIL}`
            console.error(message)
            throw new Error(message)
        }
    }

    /**
     * Looker server against which to validate looker credentials.
     * Required.
     */
    get lookerServerUrl() {
        return env[envVarNames.LOOKERSDK_BASE_URL]
    }

    /**
     * Port number that this server will run on.
     * Optional; defaults to 8081
     */
    get port() {
        return env[envVarNames.SERVER_PORT]
            ? parseInt(env[envVarNames.SERVER_PORT], 10)
            : 8080
    }

    /**
     * Whether or not to validate the Looker server SSL certificate.
     * Optional; defaults to true
     */
    get lookerServerVerifySsl() {
        return env[envVarNames.LOOKERSDK_VERIFY_SSL]
            ? env[envVarNames.LOOKERSDK_VERIFY_SSL] !== 'false'
            : true
    }

    /**
     * Service Account that will provide the requested access token.
     * Required
     */
     get serviceAccountEmail() {
        return env[envVarNames.SERVICE_ACCOUNT_EMAIL]
    }
}

let setup: Settings

/**
 * Get the settings
 */
const getSettings = () => {
    if (!setup) {
        dotenv.config()
        setup = new Settings()
    }
    return setup
}

export { getSettings }