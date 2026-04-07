const BASE = 'http://localhost:8090';

// MVP: 使用固定 admin token（生产环境替换为登录流程）
let adminToken = '';

export function setToken(token) {
  adminToken = token;
}

async function request(path, options = {}) {
  const headers = {
    'Content-Type': 'application/json',
    ...(adminToken ? { Authorization: `Bearer ${adminToken}` } : {}),
    ...options.headers,
  };
  const res = await fetch(`${BASE}${path}`, { ...options, headers });
  const json = await res.json();
  if (json.code !== 0) {
    throw new Error(json.message || '请求失败');
  }
  return json.data;
}

// --- 公开接口 ---

export const getDramaFeed = (page = 1, pageSize = 50, category = '') =>
  request(`/api/v1/drama/feed?page=${page}&pageSize=${pageSize}${category ? `&category=${category}` : ''}`);

export const getDramaDetail = (id) =>
  request(`/api/v1/drama/${id}`);

export const searchDramas = (q) =>
  request(`/api/v1/drama/search?q=${encodeURIComponent(q)}`);

// --- Admin 接口 ---

export const loginAdmin = async (phone, code) => {
  const data = await request('/api/v1/user/login', {
    method: 'POST',
    body: JSON.stringify({ phone, code }),
  });
  adminToken = data.token;
  localStorage.setItem('admin_token', data.token);
  return data;
};

export const createDrama = (payload) =>
  request('/api/v1/admin/drama/upload', {
    method: 'POST',
    body: JSON.stringify(payload),
  });

export const getStats = () =>
  request('/api/v1/admin/stats');

// 启动时恢复 token
const saved = localStorage.getItem('admin_token');
if (saved) adminToken = saved;
