import { fileURLToPath, URL } from 'url';
import { defineConfig } from 'vite';
import environment from 'vite-plugin-environment';
import vue from '@vitejs/plugin-vue';
import dotenv from 'dotenv';
import Info from 'unplugin-info/vite';

dotenv.config({ path: '../../.env' });

export default defineConfig({
    build: {
        emptyOutDir: true
    },
    optimizeDeps: {
        esbuildOptions: {
            define: {
                global: 'globalThis'
            }
        }
    },
    server: {
        proxy: {
            '/api': {
                target: 'http://127.0.0.1:4943',
                changeOrigin: true
            }
        }
    },define: {
        'process.env': process.env
    },
    plugins: [
        vue(),
        environment('all', { prefix: 'CANISTER_' }),
        environment('all', { prefix: 'DFX_' }),
        environment('all', { prefix: 'VITE_' }),
        Info()
    ],
    resolve: {
        alias: [
            {
                find: 'declarations',
                replacement: fileURLToPath(
                    new URL('../declarations', import.meta.url)
                )
            },
            {
                find: '@',
                replacement: fileURLToPath(new URL('./src', import.meta.url))
            }
        ],
        extensions: ['.js', '.ts', '.jsx', '.tsx', '.vue']
    }
});
