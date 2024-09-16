// Styles
// import '@mdi/font/css/materialdesignicons.css' // Ensure you are using css-loader

// Vuetify
import 'vuetify/styles'
import { createVuetify } from 'vuetify'
import * as components from 'vuetify/components'
import * as directives from 'vuetify/directives'
import { BlockIDV1 } from '@/theme/LightTheme'

export default createVuetify({
    components,
    directives,
    ssr: true,
    theme: {
        defaultTheme: 'light',
        themes: { 
            light: BlockIDV1,
            dark:{
                dark: true,
                colors: {           
                    primary: '#4210b4',
                }
            }
        }
    },
    icons: {
      defaultSet: 'mdi', // This is already the default value - only for display purposes
    }
})