import ActionCable from 'actioncable';
import c from 'js-cookie';

const token = `?access-token=${c.get('access-token')}`;
const client = `&client=${c.get('client')}`;
const uid = `&uid=${c.get('uid')}`;
const cable = ActionCable.createConsumer(
  `ws://localhost:3000/cable${token}${client}${uid}`,
);

export default cable;
