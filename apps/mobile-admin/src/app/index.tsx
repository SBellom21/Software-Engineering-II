import { StyleSheet, Text, View } from 'react-native';
import { UserRole } from '@arriendos/api-types';

export default function AdminLoginPlaceholder() {
  return (
    <View style={styles.container}>
      <Text style={styles.title}>Backoffice Móvil ({UserRole.ADMIN})</Text>
      <Text style={styles.subtitle}>
        Acceso restringido — TOTP MFA + Biometría obligatoria (Release 3)
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 24,
    backgroundColor: '#0f172a',
  },
  title: {
    fontSize: 20,
    fontWeight: '700',
    color: '#f8fafc',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 14,
    color: '#94a3b8',
    textAlign: 'center',
  },
});
