uniform float uTime;
uniform float uDeltaTime;
uniform float uFlowFieldInfluence;
uniform float uFlowFieldStrength;
uniform float uFlowFieldFrequency;
uniform sampler2D uBase;

#include ../includes/simplexNoise4d.glsl
void main()
 {
    float time = uTime * 0.2;
    vec2 uv = gl_FragCoord.xy / resolution.xy;
    vec4 particle = texture(uParticles, uv);
    vec4 base = texture(uBase, uv);

    // Dead
    if(particle.a >= 1.0)
    {
        particle.a = mod(particle.a, 1.0); // fix long frames
        particle.xyz = base.xyz;
    }

    // Alive
    else
    {
        // Strength
        float strength = simplexNoise4d(vec4(base.xyz, time + 1.0));
        float influence = (uFlowFieldInfluence - 0.5) * (- 2.0);
        //remap
        strength = smoothstep(influence, 1.0, strength);
        // Flow field - directions for particles
        vec3 flowField = vec3(
            simplexNoise4d(vec4(particle.xyz * uFlowFieldFrequency + 0.0, time)),
            simplexNoise4d(vec4(particle.xyz * uFlowFieldFrequency + 1.0, time)),
            simplexNoise4d(vec4(particle.xyz * uFlowFieldFrequency + 2.0, time))
        );
        // normalize
        flowField = normalize(flowField);
        // slow down
        particle.xyz += flowField * uDeltaTime * strength * uFlowFieldStrength;

        // Decay
        particle.a += uDeltaTime * 0.3;
    }

    gl_FragColor = particle;
 }