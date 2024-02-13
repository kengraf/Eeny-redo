import http from 'k6/http';
import { check, sleep } from 'k6';
export let options = {
        stages: [
                { duration: '20s', target: 100 },
        ],
};
export default function() {
        let res = http.get('https://eeny.cyber-unh.org');
        check(res, { 'status was 200': r => r.status == 200 });
        sleep(1);
}
