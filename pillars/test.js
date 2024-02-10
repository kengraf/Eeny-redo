import http from 'k6/http';
import { check, sleep } from 'k6';
export let options = {
        stages: [
                { duration: '20s', target: 100 },
        ],
};
export default function() {
        let res = http.get('https://rhwyu98e52.execute-api.us-east-2.amazonaws.com');
        check(res, { 'status was 200': r => r.status == 200 });
        sleep(1);
}
