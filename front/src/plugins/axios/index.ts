import Axios, { AxiosResponse } from 'axios';
import Cookies from 'js-cookie';

const axios = Axios.create({
  baseURL: 'http://localhost:3000/api',
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'access-token': Cookies.get('access-token'),
    'client': Cookies.get('client'),
    'uid': Cookies.get('uid'),
  },
  responseType: 'json',
});

const updateToken = (res: AxiosResponse) => {
  Cookies.set('access-token', res.headers['access-token']);
  Cookies.set('client', res.headers.client);
  Cookies.set('uid', res.headers.uid);
};

const AxiosWrapper = {
  async login(email: string, password: string) {
    const path = '/auth/sign_in';
    const params = { email, password };
    const res = await axios.post(path, params);
    updateToken(res);
    return res;
  },
  async signup(uniqueName: string, displayName: string, email: string, password: string) {
    const path = '/auth';
    const params = {
      unique_name: uniqueName,
      display_name: displayName,
      email,
      password,
    };
    const res = await axios.post(path, params);
    updateToken(res);
    return res;
  },
  async validateToken() {
    const path = '/auth/validate_token';
    const res = await axios.get(path);
    return res;
  },
};

export default AxiosWrapper;
