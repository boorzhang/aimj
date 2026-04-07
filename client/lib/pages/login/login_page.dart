import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/auth/auth_service.dart';
import '../../theme/app_theme.dart';

/// 手机号 + 验证码登录页
///
/// MVP 阶段验证码固定 1234。
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _phoneCtl = TextEditingController();
  final _codeCtl = TextEditingController();
  bool _sending = false;
  bool _logging = false;
  int _countdown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _phoneCtl.dispose();
    _codeCtl.dispose();
    _timer?.cancel();
    super.dispose();
  }

  bool get _phoneValid => _phoneCtl.text.trim().length >= 11;
  bool get _codeValid => _codeCtl.text.trim().length >= 4;

  Future<void> _sendCode() async {
    if (!_phoneValid || _sending) return;
    setState(() => _sending = true);
    // MVP: 模拟发送
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() {
      _sending = false;
      _countdown = 60;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _countdown--;
        if (_countdown <= 0) t.cancel();
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.card,
        content: Text('验证码已发送（测试环境固定 1234）', style: AppTextStyles.body),
      ),
    );
  }

  Future<void> _login() async {
    if (!_phoneValid || !_codeValid || _logging) return;
    setState(() => _logging = true);
    final err = await ref.read(authProvider.notifier).login(
          _phoneCtl.text.trim(),
          _codeCtl.text.trim(),
        );
    if (!mounted) return;
    setState(() => _logging = false);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.card,
          content: Text(err, style: AppTextStyles.body),
        ),
      );
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('登录')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Text('欢迎来到 AI短剧',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('登录后享受个性化推荐、收藏同步、金币奖励',
                  style: AppTextStyles.caption),
              const SizedBox(height: 40),

              // 手机号
              TextField(
                controller: _phoneCtl,
                keyboardType: TextInputType.phone,
                maxLength: 11,
                style: AppTextStyles.body,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: '请输入手机号',
                  hintStyle: const TextStyle(color: AppColors.textSecondary),
                  counterText: '',
                  prefixIcon: const Icon(Icons.phone_android, color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 验证码
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _codeCtl,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      style: AppTextStyles.body,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: '验证码',
                        hintStyle: const TextStyle(color: AppColors.textSecondary),
                        counterText: '',
                        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.card,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 110,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _countdown > 0 || !_phoneValid ? null : _sendCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.divider,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _sending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _countdown > 0 ? '${_countdown}s' : '获取验证码',
                              style: TextStyle(
                                color: _countdown > 0 ? AppColors.textSecondary : Colors.white,
                                fontSize: 13,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // 登录按钮
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _phoneValid && _codeValid && !_logging ? _login : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.divider,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.button),
                    ),
                  ),
                  child: _logging
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('登录 / 注册',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  '登录即同意《用户协议》和《隐私政策》',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
